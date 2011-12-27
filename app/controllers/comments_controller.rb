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
      CommentMailer.modetation_needed(@comment).deliver
    end

    redirect_to "#{post_path(@post)}#comment#{@comment.id}"
  end

  def flag
    @comment.status = 'flagged'
    @comment.save!
    flash[:notice] = "El comentario ha sido denunciado."
    redirect_to @post
  end

end
