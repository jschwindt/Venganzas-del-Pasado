module Admin
  class PostsController < BaseController
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    private

    def verify_admin
      unless current_user.can? :update, Post
        redirect_to root_url, :alert => I18n.t('unauthorized.not_admin')
      end
    end
  end
end
