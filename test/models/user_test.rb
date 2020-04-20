require 'test_helper'

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end

class UserTest < ActiveSupport::TestCase
  test 'create new user' do
    user = User.create(email: 'created@example.com', alias: "Just-Created-User", password: 'password')
    assert user.persisted?
    assert_equal user.email, 'created@example.com'
    assert_equal user.alias, 'Just-Created-User'
    assert_equal user.slug, 'just-created-user'
    assert_equal user.profile_picture_url, '//www.gravatar.com/avatar/083756b342eebb7f25294276f303d5bb?d=mm&s=50'
  end

  test 'find_for_facebook_oauth for existing user' do
    token_data = {
      extra: {
        raw_info: {
          email: 'one@example.com',
          id: 1234
        }
      }
    }.to_o

    user = User.find_for_facebook_oauth(token_data)
    assert_equal user.email, 'one@example.com'
    assert_equal user.alias, 'one'
    assert_equal user.slug, 'user-one'
    assert_equal user.fb_userid, '1234'
    assert_equal user.profile_picture_url, '//graph.facebook.com/1234/picture'
  end

  test 'find_for_facebook_oauth create user' do
    token_data = {
      extra: {
        raw_info: {
          email: 'new@example.com',
          id: 4321,
          name: 'New User Name'
        }
      }
    }.to_o

    user = User.find_for_facebook_oauth(token_data)
    assert_equal user.email, 'new@example.com'
    assert_equal user.alias, 'New User Name'
    assert_equal user.slug, 'new-user-name'
    assert_equal user.fb_userid, '4321'
    assert_equal user.profile_picture_url, '//graph.facebook.com/4321/picture'
  end
end
