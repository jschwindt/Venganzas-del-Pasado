ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # HACK, see: http://stackoverflow.com/questions/3118866/mocha-mock-carries-to-another-test
  def teardown
    super
    Mocha::Mockery.instance.teardown
    Mocha::Mockery.reset_instance
  end

end

class ActionController::TestCase
  # Add more helper methods to be used by all tests here...
  include Devise::TestHelpers
end