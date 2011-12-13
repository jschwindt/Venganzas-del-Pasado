module Admin
  class PostsController < BaseController
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    private

    def verify_admin
      unless current_user.can? :update, Post
        render '403', :status => 403
      end
    end
  end
end
