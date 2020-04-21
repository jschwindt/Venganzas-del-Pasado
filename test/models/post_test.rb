require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'should accept valid status' do
    post = post(:one)
    Post.statuses.each do |status|
      post.status = status
      assert post.valid?
    end
  end

  test 'should refuse invalid status' do
    post = post(:one)
    post.status = '--dummy_status--'
    assert post.invalid?
  end

  test 'created_on y_m_d scope' do
    posts = Post.created_on(2010)
    assert_equal posts.length, 3

    posts = Post.created_on(2010, 2)
    assert_equal posts.length, 2

    posts = Post.created_on(2010, 2, 15)
    assert_equal posts.length, 1
  end

  test 'post_count_by_month' do
    posts = Post.post_count_by_month.entries
    posts_counts = posts.select { |p| p.year == 2010 && p.month == 2 }.first
    assert_equal posts_counts.count, 2
  end

  test 'create_from_audio_file' do
    assert_difference 'Audio.count' do
      assert_difference 'Post.count' do
        fname = Rails.root.join('test/fixtures/files', 'lavenganza_2015-01-02.mp3').to_s
        post = Post.create_from_audio_file(fname)
        assert_equal post.title, 'La venganza será terrible del 02/01/2015'
      end
    end
  end

  test 'new_contribution' do
    params = ActiveSupport::HashWithIndifferentAccess.new(
      {
        title: 'New Contribution',
        created_at: Date.new(2019, 1, 2),
        media_attributes: {
          '0' => {
            asset: File.open(Rails.root.join('test/fixtures/files', 'lavenganza_2015-01-02.mp3'))
          }
        }
      }
    )
    user = user(:contributor)
    post = Post.new_contribution(params, user)
    assert post.valid?
    assert_equal post.title, 'New Contribution'
    assert_equal post.status, 'pending'
  end
end
