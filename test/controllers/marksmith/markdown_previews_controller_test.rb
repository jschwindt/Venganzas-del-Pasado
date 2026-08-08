require "test_helper"

module Marksmith
  class MarkdownPreviewsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "renders underscore emphasis as italic" do
      post markdown_previews_path, params: {
        body: "Texto _en cursiva_.",
        element_id: "markdown-preview"
      }, as: :turbo_stream

      assert_response :success
      assert_select "turbo-stream[target='markdown-preview'] em", text: "en cursiva"
      assert_select "turbo-stream[target='markdown-preview'] u", count: 0
    end

    test "does not render emphasis inside words" do
      post markdown_previews_path, params: {
        body: "Texto_en_cursiva.",
        element_id: "markdown-preview"
      }, as: :turbo_stream

      assert_response :success
      assert_select "turbo-stream[target='markdown-preview']", text: /Texto_en_cursiva\./
      assert_select "turbo-stream[target='markdown-preview'] em", count: 0
      assert_select "turbo-stream[target='markdown-preview'] u", count: 0
    end
  end
end
