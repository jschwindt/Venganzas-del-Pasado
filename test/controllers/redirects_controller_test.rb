require "test_helper"

class RedirectsControllerTest < ActionDispatch::IntegrationTest
  test "returns html 404 for unknown html paths" do
    get "/unknown-path"

    assert_response :not_found
  end

  test "returns json 404 for unknown json paths" do
    get "/.well-known/appspecific/com.chrome.devtools.json"

    assert_response :not_found
    assert_equal "not_found", response.parsed_body["error"]
  end
end
