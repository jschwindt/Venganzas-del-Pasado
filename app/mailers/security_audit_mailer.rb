class SecurityAuditMailer < ApplicationMailer
  def vulnerabilities_found
    @report = params.fetch(:report)
    @findings_by_scanner = @report.findings.group_by(&:scanner)

    mail(
      to: "juan@schwindt.org",
      subject: "[VDP] #{@report.findings.size} vulnerabilidades detectadas"
    )
  end
end
