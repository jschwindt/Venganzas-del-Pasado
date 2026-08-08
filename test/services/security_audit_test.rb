require "test_helper"
require "rbconfig"
require "stringio"

class SecurityAuditTest < ActiveSupport::TestCase
  Status = Data.define(:exitstatus) do
    def success?
      exitstatus.zero?
    end
  end

  ImportmapVulnerability = Data.define(:name, :severity, :vulnerable_versions, :vulnerability)

  test "reports a clean audit" do
    report = runner(
      gem_check: gem_payload,
      bun_check: "{}",
      importmap: []
    ).run

    assert_empty report.findings
    assert_empty report.errors
    assert_equal 0, report.exit_code
    assert_equal "No vulnerabilities found.", SecurityAudit::Formatter.call(report)
  end

  test "loads without booting Rails" do
    _stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      "-Ilib",
      "-e",
      "require 'security_audit'",
      chdir: Rails.root.to_s
    )

    assert_predicate status, :success?, stderr
  end

  test "CLI prints the report and returns its exit code" do
    report = SecurityAudit::Report.new(
      findings: [],
      errors: [ SecurityAudit::ScannerError.new(scanner: "bun", message: "registry unavailable") ]
    )
    output = StringIO.new
    fake_runner = Data.define(:report) { def run = report }.new(report:)

    exit_code = SecurityAudit::CLI.new(runner: fake_runner, output:).call

    assert_equal 2, exit_code
    assert_includes output.string, "Audit errors: 1"
    assert_includes output.string, "bun: registry unavailable"
  end

  test "normalizes vulnerabilities from every scanner" do
    gem_result = {
      type: "unpatched_gem",
      gem: { name: "rack", version: "1.0.0" },
      advisory: {
        id: "CVE-2026-0001",
        criticality: "high",
        title: "Rack vulnerability"
      }
    }
    bun_result = {
      "lodash" => [
        {
          "id" => "GHSA-test",
          "severity" => "moderate",
          "title" => "Lodash vulnerability",
          "vulnerable_versions" => "< 4.17.22"
        }
      ]
    }
    importmap_result = [
      ImportmapVulnerability.new(
        name: "@hotwired/turbo",
        severity: "low",
        vulnerable_versions: "< 8.0.0",
        vulnerability: "Turbo vulnerability"
      )
    ]

    report = runner(
      gem_check: gem_payload(gem_result),
      gem_status: 1,
      bun_check: JSON.generate(bun_result),
      bun_status: 1,
      importmap: importmap_result
    ).run

    assert_equal 3, report.findings.size
    assert_empty report.errors
    assert_equal 1, report.exit_code
    assert_equal %w[gems bun importmap], report.findings.map(&:scanner)

    gem_finding = report.findings.first
    assert_equal "rack", gem_finding.package
    assert_equal "high", gem_finding.severity
    assert_equal "CVE-2026-0001", gem_finding.identifier
    assert_equal "1.0.0", gem_finding.affected_versions
  end

  test "continues after operational errors and returns exit code two" do
    commands = []
    command_runner = lambda do |*command, chdir:|
      commands << [ command, chdir ]

      case command
      when [ "bin/bundler-audit", "update", "--quiet" ]
        [ "", "update failed", Status.new(exitstatus: 2) ]
      when [ "bin/bundler-audit", "check", "--format", "json" ]
        [ gem_payload, "", Status.new(exitstatus: 0) ]
      when [ "bun", "audit", "--json" ]
        [ "", "network failed", Status.new(exitstatus: 2) ]
      end
    end
    importmap_auditor = -> { raise Importmap::Npm::HTTPError, "registry unavailable" }

    report = SecurityAudit::Runner.new(
      root: Rails.root,
      command_runner:,
      importmap_auditor:
    ).run

    assert_empty report.findings
    assert_equal 3, report.errors.size
    assert_equal %w[gems bun importmap], report.errors.map(&:scanner)
    assert_equal 2, report.exit_code
    assert_equal 3, commands.size
    assert_includes SecurityAudit::Formatter.call(report), "Audit errors: 3"
  end

  test "returns exit code two when findings and errors coexist" do
    report = runner(
      gem_check: gem_payload,
      bun_check: JSON.generate(
        "lodash" => [ { "severity" => "high", "title" => "Vulnerable", "vulnerable_versions" => "< 4" } ]
      ),
      bun_status: 1,
      importmap: -> { raise "registry unavailable" }
    ).run

    assert_equal 1, report.findings.size
    assert_equal 1, report.errors.size
    assert_equal 2, report.exit_code
  end

  test "normalizes npm audit v2 vulnerability payloads" do
    payload = {
      "vulnerabilities" => {
        "vite" => {
          "severity" => "high",
          "range" => "< 8.2.2",
          "via" => [
            {
              "source" => 123,
              "name" => "vite",
              "title" => "Vite vulnerability",
              "url" => "https://example.com/advisory",
              "severity" => "high"
            }
          ]
        }
      }
    }

    report = runner(gem_check: gem_payload, bun_check: JSON.generate(payload), bun_status: 1, importmap: []).run
    finding = report.findings.fetch(0)

    assert_equal "vite", finding.package
    assert_equal "https://example.com/advisory", finding.identifier
    assert_equal "< 8.2.2", finding.affected_versions
  end

  private
    def runner(gem_check:, bun_check:, importmap:, gem_status: 0, bun_status: 0)
      responses = {
        [ "bin/bundler-audit", "update", "--quiet" ] => [ "", "", Status.new(exitstatus: 0) ],
        [ "bin/bundler-audit", "check", "--format", "json" ] => [ gem_check, "", Status.new(exitstatus: gem_status) ],
        [ "bun", "audit", "--json" ] => [ bun_check, "", Status.new(exitstatus: bun_status) ]
      }
      command_runner = ->(*command, chdir:) { responses.fetch(command) }
      importmap_auditor = importmap.respond_to?(:call) ? importmap : -> { importmap }

      SecurityAudit::Runner.new(root: Rails.root, command_runner:, importmap_auditor:)
    end

    def gem_payload(*results)
      JSON.generate(version: "0.9.3", results:)
    end
end
