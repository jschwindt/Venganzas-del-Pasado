require 'test_helper'

class AbilityTest < ActiveSupport::TestCase

  #---------------------------------------------
  # Tests for anonymous users
  #---------------------------------------------

  test "logout user can read only published post" do
    ability = Ability.new(nil)
    assert ability.can?(:read, posts(:published))
    assert ability.cannot?(:read, posts(:draft))
  end

  test "logged out user can read only neutral, approved or flagged comments" do
    ability = Ability.new(nil)
    assert ability.can?(:read, comments(:neutral))
    assert ability.can?(:read, comments(:approved))
    assert ability.can?(:read, comments(:flagged))
    assert ability.cannot?(:read, comments(:pending))
  end

  test "logout user can read articles" do
    ability = Ability.new(nil)
    assert ability.can?(:read, articles(:one))
  end

  test "logout user can read other users profile" do
    ability = Ability.new(nil)
    assert ability.can?(:read, users(:one))
  end

  #---------------------------------------------
  # Tests for logged in plain user
  #---------------------------------------------

  test "user can create comments" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.can?(:create, user.comments.new)
  end

  test "user can read his/her pending comments but no other's" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.can?(:read, user.comments.new)
    assert ability.cannot?(:read, comments(:pending))
  end

  test "user cannot update any comments" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.cannot?(:update, user.comments.new)
    assert ability.cannot?(:update, Comment.new)
  end

  test "user cannot destroy any comments" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.cannot?(:destroy, user.comments.new)
    assert ability.cannot?(:destroy, Comment.new)
  end

  test "user can flag any comments" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.can?(:flag, Comment.new)
  end

  test "user can like or dislike any comments" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.can?(:like, Comment.new)
    assert ability.can?(:dislike, Comment.new)
  end

  test "good users can post their comments" do
    user = users(:one)
    user.karma = 600
    ability = Ability.new(user)
    assert ability.can?(:publish, user.comments.build)
  end

  test "user cannot manage all" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.cannot?(:manage, :all)
  end

  #---------------------------------------------
  # Tests for moderators
  #---------------------------------------------

  test "moderators can approve comments" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.can?(:approve, Comment.new)
  end

  test "moderators can trash comments" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.can?(:trash, Comment.new)
  end

  test "moderators cannot update comments" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.cannot?(:update, Comment.new)
  end

  test "moderators cannot destroy comments" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.cannot?(:destroy, Comment.new)
  end

  test "moderators cannot manage all" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.cannot?(:manage, :all)
  end

  #---------------------------------------------
  # Tests for editors
  #---------------------------------------------

  test "editors can approve comments" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.can?(:approve, Comment.new)
  end

  test "editors can trash comments" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.can?(:trash, Comment.new)
  end

  test "editors cannot update comments" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.cannot?(:update, Comment.new)
  end

  test "editors cannot destroy comments" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.cannot?(:destroy, Comment.new)
  end

  test "editors can update posts" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.can?(:update, posts(:one))
  end

  test "editors cannot manage all" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.cannot?(:manage, :all)
  end

  #---------------------------------------------
  # Tests for admins
  #---------------------------------------------

  test "admins can do anything" do
    user = users(:admin)
    ability = Ability.new(user)
    assert ability.can?(:manage, :all)
  end

end
