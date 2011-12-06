# encoding: utf-8

class CommentsController < ApplicationController
  load_and_authorize_resource :post
  load_and_authorize_resource :comment, :through => :post

  def create
    @comment = @post.comments.new(params[:comment]).publish_as(current_user, request)
    @comment.save

    if @comment.approved?
      flash[:notice] = "Tu comentario ha sido publicado."
    else
      flash[:notice] = "Tu comentario se ha guardado, y está pendiente de aprobación."
    end

    redirect_to "#{post_path(@post)}#comment#{@comment.id}"
  end

  def update
    @comment.update_attributes(params[:comment])
    flash[:notice] = "Los cambios al comentario han sido guardados."
    redirect_to post_comment_path(@post, @comment)
  end

  def destroy
    @comment.destroy
    flash[:notice] = "El comentario ha sido eliminado."
    redirect_to post_path(@post)
  end

end
