require 'test_helper'

class PostTest < ActiveSupport::TestCase

  should have_many(:comments).dependent(:destroy)
  should have_many(:audios).dependent(:destroy)
  should have_many(:media).dependent(:destroy)
  should belong_to(:contributor)
  should validate_presence_of(:title)

  test "should be valid" do
    assert posts(:one).valid?
  end

  test "should accept nested attributes for media" do
    assert Post.instance_methods.include?(:media_attributes=)
  end

  test "should accept valid status" do
    post = posts(:one)
    Post.statuses.each do |status|
      post.status = status
      assert post.valid?
    end
  end

  test "should refuse invalid status" do
    post = posts(:one)
    post.status = '--dummy_status--'
    assert post.invalid?
  end

end
