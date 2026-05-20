require "test_helper"

class AdminAffiliateLinksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "redirect to login if logged out" do
    get admin_affiliate_links_url
    assert_redirected_to new_user_session_url
  end

  test "denied access to plain users, editors and moderators" do
    sign_in users(:one)
    get admin_affiliate_links_url
    assert_response 403

    sign_in users(:editor)
    get admin_affiliate_links_url
    assert_response 403

    sign_in users(:moderator)
    get admin_affiliate_links_url
    assert_response 403
  end

  test "show affiliate links to admins" do
    sign_in users(:admin)
    get admin_affiliate_links_url
    assert_response :success
  end

  test "should show new form" do
    sign_in users(:admin)
    get new_admin_affiliate_link_url
    assert_response :success
  end

  test "should create affiliate link" do
    sign_in users(:admin)
    post(
      admin_affiliate_links_url,
      params: {
        affiliate_link: {
          name: "Libro",
          product_url: "https://www.mercadolibre.com.ar/libro",
          affiliate_url: "https://www.mercadolibre.com.ar/affiliate/libro",
          image_url: "https://http2.mlstatic.com/libro.jpg",
          price: 1000.5,
          active: true
        }
      }
    )
    assert_equal flash[:notice], "Creado correctamente."
    assert_response 302
  end

  test "should show edit form" do
    sign_in users(:admin)
    get edit_admin_affiliate_link_url(affiliate_links(:one))
    assert_response :success
  end

  test "should update affiliate link" do
    sign_in users(:admin)
    affiliate_link = affiliate_links(:one)
    patch(
      admin_affiliate_link_url(affiliate_link),
      params: {
        affiliate_link: { name: "Libro actualizado", active: false }
      }
    )
    assert_equal flash[:notice], "Se han guardado los cambios."
    assert_redirected_to edit_admin_affiliate_link_url(affiliate_link)
  end

  test "should destroy affiliate link" do
    sign_in users(:admin)
    assert_difference("AffiliateLink.count", -1) do
      delete admin_affiliate_link_url(affiliate_links(:one))
    end
    assert_redirected_to admin_affiliate_links_url
  end
end
