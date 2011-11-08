Kaminari.configure do |config|
  # config.default_per_page = 25
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.param_name = :page
end

module Kaminari
  module Helpers
    class Tag
      def page_url_for(page)
        @template.url_for @template.params.merge(@param_name => (page < 1 ? nil : page))
      end
    end
  end
end
