require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get posts index" do
    get posts_url
    assert_response :success
  end

  test "should get posts index rss" do
    get posts_url(format: :rss)
    assert_response :success
  end

  test "should show post" do
    get post_url posts(:published)
    assert_response :success
  end

  test "should get archive" do
    get posts_archive_url year: 2010
    assert_response :success
  end

  test "should get archive xhr" do
    get posts_archive_url(year: 2010), xhr: true
    assert_response :success
  end

  test "should get contributions" do
    get contributions_url
    assert_response :success
  end

  test "should get latest posts without content as json" do
    posts = 11.times.map do |i|
      post = Post.create!(
        title: "Without content #{i}",
        content: i.even? ? "" : nil,
        status: "published",
        created_at: i.days.ago
      )
      Audio.create!(post: post, url: "http://example.com/without-content-#{i}.mp3")
      post
    end
    Post.create!(
      title: "With content",
      content: "Some content",
      status: "published",
      created_at: Time.current
    )

    get without_content_posts_url(format: :json)

    assert_response :success
    assert_equal "application/json", response.media_type

    response_posts = response.parsed_body
    assert_equal 10, response_posts.size
    assert_equal posts.first.id, response_posts.first["id"]
    assert_equal posts.first.title, response_posts.first["title"]
    assert_equal posts.first.audios.first.id, response_posts.first["audio_id"]
    assert_not_includes response_posts.map { |post| post["title"] }, "With content"
    assert_not_includes response_posts.map { |post| post["id"] }, posts.last.id
  end

  test "logged out new contribution should redirect to login" do
    get new_post_url
    assert_redirected_to new_user_session_url
  end

  test "logged in contribution should show form" do
    sign_in users(:one)
    get new_post_url
    assert_response :success
  end

  test "logged out create contribution should redirect to login" do
    post posts_url
    assert_redirected_to new_user_session_url
  end

  test "logged in create contribution should fail" do
    sign_in users(:one)
    assert_no_difference "Post.count" do
      post posts_url, params: { post: { title: "" } }
      assert_response :success
    end
  end

  test "logged in create contribution should create" do
    sign_in users(:one)
    params = {
      post: {
        title: "New Contribution",
        created_at: Date.new(2019, 1, 2),
        media_attributes: {
          "0" => {
            asset: Rack::Test::UploadedFile.new(
              Rails.root.join("test/fixtures/files", "lavenganza_2015-01-02.mp3"),
              "audio/mpeg"
            )
          }
        }
      }
    }
    assert_difference "Post.count" do
      post posts_url, params: params
      assert_equal ActionMailer::Base.deliveries.first.subject, "Hay una nueva contribución"
      assert_redirected_to new_post_url
    end
  end
end
