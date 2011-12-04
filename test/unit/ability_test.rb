require 'test_helper'

class AbilityTest < ActiveSupport::TestCase

  test "user can only edit comments which he owns" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.can?(:edit, Comment.new(:user => user))
    assert ability.cannot?(:edit, Comment.new)
  end

  test "user can only destroy comments which he owns" do
    user = users(:one)
    ability = Ability.new(user)
    assert ability.can?(:destroy, Comment.new(:user => user))
    assert ability.cannot?(:destroy, Comment.new)
  end

  test "moderators can update comments" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.can?(:update, Comment.new)
  end

  test "moderators can destroy comments" do
    user = users(:moderator)
    ability = Ability.new(user)
    assert ability.can?(:destroy, Comment.new)
  end

  test "editors can update comments" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.can?(:update, Comment.new)
  end

  test "editors can destroy comments" do
    user = users(:editor)
    ability = Ability.new(user)
    assert ability.can?(:destroy, Comment.new)
  end

  test "good users can approve comments" do
    user = users(:one)
    user.karma = 600
    ability = Ability.new(user)
    assert ability.can?(:approve, Comment.new)
  end

end
