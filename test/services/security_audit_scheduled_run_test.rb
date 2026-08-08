require "test_helper"

class SecurityAuditScheduledRunTest < ActiveSupport::TestCase
  FakeRunner = Data.define(:report) do
    def run
      report
    end
  end

  class FakeMailer
    attr_reader :reports, :deliveries

    def initialize(delivery_error: nil)
      @reports = []
      @deliveries = 0
      @delivery_error = delivery_error
    end

    def with(report:)
      reports << report
      self
    end

    def vulnerabilities_found
      self
    end

    def deliver_now
      raise @delivery_error if @delivery_error

      @deliveries += 1
    end
  end

  test "does not email a clean audit" do
    mailer = FakeMailer.new
    result = scheduled_run(report, mailer:).call

    assert_equal 0, mailer.deliveries
    assert_empty mailer.reports
    assert_equal 0, result.exit_code
  end

  test "emails one consolidated report when vulnerabilities exist" do
    mailer = FakeMailer.new
    vulnerable_report = report(findings: [ finding("gems"), finding("bun") ])
    result = scheduled_run(vulnerable_report, mailer:).call

    assert_equal 1, mailer.deliveries
    assert_equal [ vulnerable_report ], mailer.reports
    assert_equal 1, result.exit_code
  end

  test "does not email operational errors without findings" do
    mailer = FakeMailer.new
    incomplete_report = report(errors: [ scanner_error ])
    result = scheduled_run(incomplete_report, mailer:).call

    assert_equal 0, mailer.deliveries
    assert_empty mailer.reports
    assert_equal 2, result.exit_code
  end

  test "emails findings and preserves a partial audit status" do
    mailer = FakeMailer.new
    partial_report = report(findings: [ finding("bun") ], errors: [ scanner_error ])
    result = scheduled_run(partial_report, mailer:).call

    assert_equal 1, mailer.deliveries
    assert_equal 2, result.exit_code
    assert_predicate result, :incomplete?
  end

  test "turns an email delivery failure into an operational error" do
    mailer = FakeMailer.new(delivery_error: RuntimeError.new("smtp unavailable"))
    result = scheduled_run(report(findings: [ finding("gems") ]), mailer:).call

    assert_equal 2, result.exit_code
    assert_equal "email", result.errors.last.scanner
    assert_includes result.errors.last.message, "smtp unavailable"
  end

  private
    def scheduled_run(report, mailer:)
      SecurityAudit::ScheduledRun.new(runner: FakeRunner.new(report:), mailer:)
    end

    def report(findings: [], errors: [])
      SecurityAudit::Report.new(findings:, errors:)
    end

    def finding(scanner)
      SecurityAudit::Finding.new(
        scanner:,
        package: "example",
        severity: "high",
        identifier: "CVE-2026-0001",
        description: "Example vulnerability",
        affected_versions: "< 2"
      )
    end

    def scanner_error
      SecurityAudit::ScannerError.new(scanner: "importmap", message: "registry unavailable")
    end
end
