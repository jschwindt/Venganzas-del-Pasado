require "minitest/autorun"
require_relative "../../lib/required_environment"

class RequiredEnvironmentTest < Minitest::Test
  def test_ignores_missing_variables_outside_production
    RequiredEnvironment.validate!(environment: "test", values: {})
  end

  def test_accepts_complete_production_environment
    values = RequiredEnvironment::PRODUCTION_VARIABLES.to_h { |name| [ name, "configured" ] }

    RequiredEnvironment.validate!(environment: "production", values: values)
  end

  def test_reports_every_missing_production_variable
    values = RequiredEnvironment::PRODUCTION_VARIABLES.to_h { |name| [ name, "configured" ] }
    values["RECAPTCHA_SECRET_KEY"] = ""
    values.delete("AUDIO_API_SECRET_TOKEN")

    error = assert_raises(KeyError) do
      RequiredEnvironment.validate!(environment: "production", values: values)
    end

    assert_includes error.message, "RECAPTCHA_SECRET_KEY"
    assert_includes error.message, "AUDIO_API_SECRET_TOKEN"
  end
end
