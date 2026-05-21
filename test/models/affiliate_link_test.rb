require "test_helper"

class AffiliateLinkTest < ActiveSupport::TestCase
  test "defaults active to true" do
    assert AffiliateLink.new.active?
  end

  test "random active returns up to four active links" do
    affiliate_links = AffiliateLink.random_active

    assert_operator affiliate_links.size, :<=, 4
    assert affiliate_links.all?(&:active?)
  end

  test "random active does not repeat products" do
    affiliate_links = AffiliateLink.random_active
    product_urls = affiliate_links.map(&:product_url)

    assert_equal product_urls.uniq, product_urls
  end

  test "requires name, product url and affiliate url" do
    affiliate_link = AffiliateLink.new

    assert_not affiliate_link.valid?
    assert affiliate_link.errors[:name].any?
    assert affiliate_link.errors[:product_url].any?
    assert affiliate_link.errors[:affiliate_url].any?
  end

  test "builds metadata from metainspector page" do
    page = FakePage.new(
      best_title: "Producto destacado",
      title: "Producto",
      url: "https://www.mercadolibre.com.ar/producto",
      image_url: "https://http2.mlstatic.com/producto.jpg"
    )

    with_singleton_stub(MetaInspector, :new, page) do
      metadata = AffiliateLink.metadata_for("https://mercadolibre.com.ar/affiliate")

      assert_equal "Producto destacado", metadata[:name]
      assert_equal "https://www.mercadolibre.com.ar/producto", metadata[:product_url]
      assert_equal "https://http2.mlstatic.com/producto.jpg", metadata[:image_url]
      assert_nil metadata[:price]
    end
  end

  class FakePage
    attr_reader :best_title, :title, :url

    def initialize(best_title:, title:, url:, image_url:)
      @best_title = best_title
      @title = title
      @url = url
      @images = FakeImages.new(image_url)
    end

    def images
      @images
    end
  end

  class FakeImages
    def initialize(best)
      @best = best
    end

    def best
      @best
    end
  end

  private

  def with_singleton_stub(object, method_name, value)
    original_method = object.method(method_name)
    object.define_singleton_method(method_name) { |*_args| value }
    yield
  ensure
    object.define_singleton_method(method_name, original_method)
  end
end
