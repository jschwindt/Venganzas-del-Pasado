# encoding: utf-8

class CommentsController < ApplicationController
  load_and_authorize_resource :post, :only => [:create, :show]
  load_and_authorize_resource :comment, :only => [:flag, :like, :dislike, :opinions]
  load_and_authorize_resource :comment, :through => :post, :only => [:create, :show]

  def create
    @comment = @post.comments.new(params[:comment]).publish_as(current_user, request)
    @comment.save

    if @comment.pending?
      flash[:notice] = "Tu comentario se ha guardado, y está pendiente de aprobación."
      CommentMailer.moderation_needed(@comment, "Comentario para moderar").deliver
    else
      flash[:notice] = "Tu comentario ha sido publicado."
    end

    redirect_to "#{post_path(@post)}#comment#{@comment.id}"
  end

  def flag
    @comment.flag!
    CommentMailer.moderation_needed(@comment, "Comentario denunciado").deliver
  end

  def like
    current_user.like! @comment
  end

  def dislike
    current_user.dislike! @comment
  end

  def opinions
    render :layout => false
  end

end
