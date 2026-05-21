require "test_helper"

class LayoutsWidgetsReferralsTest < ActionView::TestCase
  test "renders up to four active affiliate links" do
    render partial: "layouts/widgets/referrals"

    assert_select "h3", text: "Compras afiliadas"
    assert_select ".referrals .referral-card", maximum: 4
    assert_select ".referrals .referral-card[href=?]", affiliate_links(:inactive).affiliate_url, count: 0
    assert_no_match "amzn.to", rendered
    assert_no_match "Libros recomendados", rendered
  end

  test "renders links with affiliate url and blank target assertions" do
    link = affiliate_links(:one)

    with_random_active(link) do
      render partial: "layouts/widgets/referrals"
    end

    assert_select ".referral-card[href=?]", link.affiliate_url
    assert_select ".referral-card[target=?]", "_blank"
    assert_select ".referral-card[rel=?]", "noopener sponsored"
    assert_select ".referral-card img[src=?][alt=?]", link.image_url, link.name
    assert_select ".referral-card-title", text: link.name
  end

  test "renders fallback card without image" do
    link = affiliate_links(:one)
    link.update!(image_url: "")

    with_random_active(link) do
      render partial: "layouts/widgets/referrals"
    end

    assert_select ".referral-card img", count: 0
    assert_select ".referral-card-title", text: link.name
  end

  test "does not render widget without active affiliate links" do
    with_random_active(nil) do
      render partial: "layouts/widgets/referrals"
    end

    assert_no_match "Compras afiliadas", rendered
    assert_select ".referrals", count: 0
  end

  private

  def with_random_active(link)
    original_method = AffiliateLink.method(:random_active)
    AffiliateLink.define_singleton_method(:random_active) do
      link ? link.class.where(id: link.id) : AffiliateLink.none
    end
    yield
  ensure
    AffiliateLink.define_singleton_method(:random_active, original_method)
  end
end
