require "test_helper"

class SecurityAuditMailerTest < ActionMailer::TestCase
  test "renders a consolidated vulnerability report" do
    report = SecurityAudit::Report.new(
      findings: [
        SecurityAudit::Finding.new(
          scanner: "gems",
          package: "rack",
          severity: "high",
          identifier: "CVE-2026-0001",
          description: "Rack vulnerability",
          affected_versions: "1.0.0"
        ),
        SecurityAudit::Finding.new(
          scanner: "bun",
          package: "vite",
          severity: "moderate",
          identifier: "GHSA-test",
          description: "Vite vulnerability",
          affected_versions: "< 8.2.2"
        )
      ],
      errors: [ SecurityAudit::ScannerError.new(scanner: "importmap", message: "registry unavailable") ]
    )

    mail = SecurityAuditMailer.with(report:).vulnerabilities_found

    assert_equal "[VDP] 2 vulnerabilidades detectadas", mail.subject
    assert_equal [ "juan@schwindt.org" ], mail.to
    assert_equal [ "no-responder@venganzasdelpasado.com.ar" ], mail.from
    assert_match "Rack vulnerability", mail.body.encoded
    assert_match "Vite vulnerability", mail.body.encoded
    assert_match "Auditor=C3=ADa incompleta", mail.body.encoded
    assert_match "registry unavailable", mail.body.encoded
  end
end
