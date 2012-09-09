# encoding: utf-8

module Admin
  class CommentsController < BaseController
    load_and_authorize_resource
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    def approve
      @comment = Comment.find params[:id]
      @comment.approve!
      flash[:notice] = "Se ha aprobado el comentario."
      redirect_to collection_url(:has_status => 'pending')
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
        collection_url(:has_status => 'deleted')
      end
    end

    private

    def verify_admin
      unless current_user.can?(:approve, Comment)
        render '403', :status => 403
      end
    end

  end
end
