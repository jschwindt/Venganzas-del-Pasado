require "json"
require "open3"
require "pathname"
require "importmap-rails"
require "importmap/map"
require "importmap/npm"

module SecurityAudit
  Finding = Data.define(
    :scanner,
    :package,
    :severity,
    :identifier,
    :description,
    :affected_versions
  )

  ScannerError = Data.define(:scanner, :message)

  Report = Data.define(:findings, :errors) do
    def exit_code
      return 2 if errors.any?
      return 1 if findings.any?

      0
    end

    def vulnerable?
      findings.any?
    end

    def incomplete?
      errors.any?
    end
  end

  class Runner
    def initialize(root: Pathname.pwd, command_runner: Open3.method(:capture3), importmap_auditor: nil)
      @root = Pathname(root)
      @command_runner = command_runner
      @importmap_auditor = importmap_auditor || method(:audit_importmap)
    end

    def run
      findings = []
      errors = []

      audit_gems(findings, errors)
      audit_bun(findings, errors)
      audit_importmap_packages(findings, errors)

      Report.new(findings:, errors:)
    end

    private
      attr_reader :root, :command_runner, :importmap_auditor

      def audit_gems(findings, errors)
        update = run_command("gems", "bin/bundler-audit", "update", "--quiet")
        errors << command_error("gems", "advisory database update", update) unless update.success?

        check = run_command("gems", "bin/bundler-audit", "check", "--format", "json")
        return errors << command_error("gems", "vulnerability check", check) unless check.expected_audit_status?

        results = JSON.parse(check.stdout).fetch("results")
        findings.concat(results.filter_map { |result| normalize_gem_finding(result) })

        if check.failed? && results.empty?
          errors << ScannerError.new(scanner: "gems", message: "Audit exited with status 1 without reporting a vulnerability")
        end
      rescue JSON::ParserError, KeyError => error
        errors << ScannerError.new(scanner: "gems", message: "Invalid bundler-audit JSON: #{error.message}")
      rescue => error
        errors << unexpected_error("gems", error)
      end

      def audit_bun(findings, errors)
        result = run_command("bun", "bun", "audit", "--json")
        return errors << command_error("bun", "vulnerability check", result) unless result.expected_audit_status?

        payload = JSON.parse(result.stdout)
        bun_findings = normalize_bun_findings(payload)
        findings.concat(bun_findings)

        if result.failed? && bun_findings.empty?
          errors << ScannerError.new(scanner: "bun", message: "Audit exited with status 1 without reporting a vulnerability")
        end
      rescue JSON::ParserError => error
        errors << ScannerError.new(scanner: "bun", message: "Invalid bun audit JSON: #{error.message}")
      rescue => error
        errors << unexpected_error("bun", error)
      end

      def audit_importmap_packages(findings, errors)
        importmap_auditor.call.each do |vulnerability|
          findings << Finding.new(
            scanner: "importmap",
            package: vulnerability.name,
            severity: vulnerability.severity,
            identifier: nil,
            description: vulnerability.vulnerability,
            affected_versions: vulnerability.vulnerable_versions
          )
        end
      rescue => error
        errors << unexpected_error("importmap", error)
      end

      def audit_importmap
        Importmap::Npm.new(
          root.join("config/importmap.rb").to_s,
          vendor_path: root.join("vendor/javascript").to_s
        ).vulnerable_packages
      end

      def normalize_gem_finding(result)
        case result.fetch("type")
        when "unpatched_gem"
          gem = result.fetch("gem")
          advisory = result.fetch("advisory")

          Finding.new(
            scanner: "gems",
            package: gem.fetch("name"),
            severity: advisory["criticality"] || "unknown",
            identifier: advisory["id"] || advisory["cve"] || advisory["ghsa"],
            description: advisory["title"] || advisory["description"],
            affected_versions: gem["version"]
          )
        when "insecure_source"
          Finding.new(
            scanner: "gems",
            package: result.fetch("source").to_s,
            severity: "unknown",
            identifier: "insecure_source",
            description: "Gem source does not use a secure transport",
            affected_versions: nil
          )
        end
      end

      def normalize_bun_findings(payload)
        return normalize_npm_vulnerabilities(payload.fetch("vulnerabilities")) if payload.key?("vulnerabilities")
        return normalize_bun_advisories(payload.fetch("advisories")) if payload.key?("advisories")

        normalize_bun_advisories(payload)
      end

      def normalize_bun_advisories(advisories)
        advisories.flat_map do |package, entries|
          Array(entries).filter_map { |entry| normalize_bun_entry(package, entry) }
        end
      end

      def normalize_npm_vulnerabilities(vulnerabilities)
        vulnerabilities.flat_map do |package, details|
          entries = Array(details["via"]).select { |entry| entry.is_a?(Hash) }
          entries = [ details ] if entries.empty?

          entries.map { |entry| normalize_bun_entry(package, entry.merge("range" => details["range"])) }
        end
      end

      def normalize_bun_entry(package, entry)
        return unless entry.is_a?(Hash)

        Finding.new(
          scanner: "bun",
          package: entry["name"] || entry["module_name"] || package,
          severity: entry["severity"] || "unknown",
          identifier: entry["id"]&.to_s || entry["cve"] || entry["ghsa"] || entry["url"],
          description: entry["title"] || entry["description"] || "Known package vulnerability",
          affected_versions: entry["vulnerable_versions"] || entry["range"]
        )
      end

      def run_command(scanner, *command)
        stdout, stderr, status = command_runner.call(*command, chdir: root.to_s)
        CommandResult.new(scanner:, command:, stdout:, stderr:, status:)
      rescue => error
        CommandResult.new(
          scanner:,
          command:,
          stdout: "",
          stderr: "#{error.class}: #{error.message}",
          status: nil
        )
      end

      def command_error(scanner, operation, result)
        detail = [ result.stderr, result.stdout ].find { |output| !output.to_s.empty? } || "unknown error"
        ScannerError.new(scanner:, message: "#{operation} failed: #{detail.strip}")
      end

      def unexpected_error(scanner, error)
        ScannerError.new(scanner:, message: "#{error.class}: #{error.message}")
      end
  end

  CommandResult = Data.define(:scanner, :command, :stdout, :stderr, :status) do
    def success?
      status&.success? == true
    end

    def failed?
      !success?
    end

    def expected_audit_status?
      success? || status&.exitstatus == 1
    end
  end

  class Formatter
    def self.call(report)
      new(report).call
    end

    def initialize(report)
      @report = report
    end

    def call
      lines = []

      if report.findings.empty?
        lines << (report.incomplete? ? "No vulnerabilities found by the scanners that completed." : "No vulnerabilities found.")
      else
        lines << "Vulnerabilities found: #{report.findings.size}"
        report.findings.group_by(&:scanner).each do |scanner, findings|
          lines << ""
          lines << "#{scanner}:"
          findings.each { |finding| lines << format_finding(finding) }
        end
      end

      if report.errors.any?
        lines << ""
        lines << "Audit errors: #{report.errors.size}"
        report.errors.each { |error| lines << "- #{error.scanner}: #{error.message}" }
      end

      lines.join("\n")
    end

    private
      attr_reader :report

      def format_finding(finding)
        details = [ finding.identifier, finding.affected_versions ].compact.join("; ")
        suffix = details.empty? ? "" : " (#{details})"
        "- [#{finding.severity}] #{finding.package}: #{finding.description}#{suffix}"
      end
  end

  class CLI
    def initialize(runner: Runner.new, output: $stdout)
      @runner = runner
      @output = output
    end

    def call
      report = runner.run
      output.puts Formatter.call(report)
      report.exit_code
    end

    private
      attr_reader :runner, :output
  end

  class ScheduledRun
    def initialize(runner: Runner.new, mailer: SecurityAuditMailer)
      @runner = runner
      @mailer = mailer
    end

    def call
      report = runner.run
      return report unless report.vulnerable?

      mailer.with(report:).vulnerabilities_found.deliver_now
      report
    rescue => error
      Report.new(
        findings: report&.findings || [],
        errors: (report&.errors || []) + [ ScannerError.new(scanner: "email", message: "#{error.class}: #{error.message}") ]
      )
    end

    private
      attr_reader :runner, :mailer
  end
end
