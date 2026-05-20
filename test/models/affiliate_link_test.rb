require "test_helper"

class AffiliateLinkTest < ActiveSupport::TestCase
  test "requires name, product url and affiliate url" do
    affiliate_link = AffiliateLink.new

    assert_not affiliate_link.valid?
    assert affiliate_link.errors[:name].any?
    assert affiliate_link.errors[:product_url].any?
    assert affiliate_link.errors[:affiliate_url].any?
  end
end
