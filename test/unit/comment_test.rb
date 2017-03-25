require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  should belong_to(:post)
  should belong_to(:user)
  should validate_presence_of(:post_id)
  should validate_presence_of(:content)

  test "should be valid" do
    assert comments(:one).valid?
  end

  test "should have an initial status of neutral" do
    comment = Comment.new
    assert comment.neutral?
  end

  test "should transition to approved" do
    [:pending, :flagged, :deleted, :approved].each do |status|
      assert comments(status).approve
    end
    [:neutral].each do |status|
      assert_raise AASM::InvalidTransition do
        comments(status).approve
      end
    end
  end

  test "should transition to pending if moderation is needed" do
    comment = Comment.new
    comment.moderate
    assert comment.pending?
    [:approved, :pending, :flagged, :deleted].each do |status|
      assert_raise AASM::InvalidTransition do
        comments(status).moderate
      end
    end
  end

  test "should transition to flagged from neutral only" do
    comment = Comment.new
    comment.flag
    assert comment.flagged?
    [:approved, :pending, :flagged, :deleted].each do |status|
      assert_raise AASM::InvalidTransition do
        comments(status).flag
      end
    end
  end

  test "should transition to deleted from any state except deleted" do
    [:pending, :flagged, :approved, :neutral].each do |status|
      assert comments(status).trash
    end
    [:deleted].each do |status|
      assert_raise AASM::InvalidTransition do
        comments(status).trash
      end
    end
  end

end
