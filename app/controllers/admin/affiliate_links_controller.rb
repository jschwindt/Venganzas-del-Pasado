module Admin
  class AffiliateLinksController < BaseController
    before_action :load_collection, only: :index
    before_action :load_resource, except: %i[index new create]
    authorize_resource
    has_scope :lifo, type: :boolean, default: true

    protected

    def verify_admin
      render("403", status: 403) unless current_user.can?(:manage, AffiliateLink)
    end

    def load_collection
      @affiliate_links = apply_scopes(AffiliateLink)
    end

    def load_resource
      @affiliate_link = AffiliateLink.find(params[:id])
    end

    def affiliate_link_params
      params.require(:affiliate_link).permit(
        %i[name product_url affiliate_url image_url price active]
      )
    end
  end
end
