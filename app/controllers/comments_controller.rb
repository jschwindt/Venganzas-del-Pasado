# encoding: utf-8

class CommentsController < ApplicationController
  load_and_authorize_resource :post
  load_and_authorize_resource :comment, :through => :post

  def create
    @comment = @post.comments.new(params[:comment]).publish_as(current_user, request)
    @comment.save

    if @comment.pending?
      flash[:notice] = "Tu comentario se ha guardado, y está pendiente de aprobación."
      CommentMailer.modetation_needed(@comment).deliver
    else
      flash[:notice] = "Tu comentario ha sido publicado."
    end

    redirect_to "#{post_path(@post)}#comment#{@comment.id}"
  end

  def flag
    @comment.flag!
    flash[:notice] = "El comentario ha sido denunciado."
    redirect_to @post
  end

end
