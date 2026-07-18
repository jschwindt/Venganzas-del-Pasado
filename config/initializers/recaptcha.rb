Recaptcha.configure do |config|
  config.site_key = ENV["RECAPTCHA_SITE_KEY"].presence || Rails.application.credentials.dig(:recaptcha_v2, :key)
  config.secret_key = ENV["RECAPTCHA_SECRET_KEY"].presence || Rails.application.credentials.dig(:recaptcha_v2, :secret)
end
