# encoding: utf-8

module Admin
  class CommentsController < BaseController
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    def approve
      set_status 'approved' do
        flash[:notice] = "Se ha aprobado el comentario."
      end
    end

    def trash
      set_status 'deleted' do
        flash[:notice] = "Se ha eliminado el comentario."
      end
    end

    private

    def set_status( status, &block )
      @comment = Comment.find params[:id]
      @comment.status = status
      @comment.save!
      yield
      redirect_to collection_url
    end

    def verify_admin
      unless current_user.can? :manage, Comment
        render '403', :status => 403
      end
    end

  end
end
