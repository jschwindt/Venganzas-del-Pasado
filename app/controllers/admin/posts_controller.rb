module Admin
  class PostsController < BaseController
    before_action :load_collection, only: :index
    before_action :load_resource, except: :index
    authorize_resource
    has_scope :has_status
    has_scope :lifo, type: :boolean, default: true

    def approve_contribution
      @post.approve_contribution!
      redirect_to @post
    end

    protected

    def verify_admin
      render '403', status: 403 unless current_user.can? :update, Post
    end

    def load_collection
      @posts = apply_scopes Post
    end

    def load_resource
      @post = Post.find(params[:id])
    end
  end
end
