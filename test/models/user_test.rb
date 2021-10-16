require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'create new user' do
    assert_difference 'User.count' do
      user = User.create(email: 'created@example.com', alias: "Just-Created-User", password: 'password')
      assert_equal user.email, 'created@example.com'
      assert_equal user.alias, 'Just-Created-User'
      assert_equal user.slug, 'just-created-user'
      assert_equal user.profile_picture_url, '//www.gravatar.com/avatar/083756b342eebb7f25294276f303d5bb?d=mm&s=50'
    end
  end
end
