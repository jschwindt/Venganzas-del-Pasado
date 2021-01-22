Recaptcha.configure do |config|
  config.site_key = Rails.application.credentials.recaptcha_v2[:key]
  config.secret_key = Rails.application.credentials.recaptcha_v2[:secret]
end
