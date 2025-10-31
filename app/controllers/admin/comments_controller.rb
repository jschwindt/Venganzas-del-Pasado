module Admin
  class CommentsController < BaseController
    before_action :load_collection, only: :index
    before_action :load_resource, except: :index
    authorize_resource
    has_scope :has_status
    has_scope :lifo, type: :boolean, default: true

    def approve
      @comment = Comment.find params[:id]
      @comment.approve!
      flash[:notice] = "Se ha aprobado el comentario."
      redirect_to collection_url(has_status: "pending")
    end

    def trash
      @comment = Comment.find params[:id]
      @comment.trash!
      flash[:notice] = "Se ha eliminado el comentario."
      redirect_to collection_url
    end

    def destroy
      destroy! do
        flash[:notice] = "Se ha eliminado definitivamente el comentario."
        collection_url(has_status: "deleted")
      end
    end

    protected

    def verify_admin
      render "403", status: 403 unless current_user.can?(:approve, Comment)
    end

    def load_collection
      @comments = apply_scopes Comment
    end

    def load_resource
      @comment = Comment.find(params[:id])
    end
  end
end
