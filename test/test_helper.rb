ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start

require_relative '../config/environment'
require 'rails/test_help'

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end

# reindex models
Post.reindex!
Comment.reindex!
Text.reindex!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: 1)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
