class CommentsController < ApplicationController
  before_action :load_post, only: %i[create show]
  load_and_authorize_resource :comment, only: %i[flag]
  load_and_authorize_resource :comment, through: :post, only: %i[create show]

  def create
    @comment = @post.comments.new(comment_params).publish_as(current_user, request)
    if @comment.save
      if @comment.pending?
        flash[:warning] = 'Tu comentario se ha guardado, y está pendiente de aprobación.'
        CommentMailer.with(comment: @comment, subject: 'Comentario para moderar')
                     .moderation_needed.deliver_now
      end
    end

    return if request.xhr?

    redirect_to "#{post_path(@post)}#comment-#{@comment.id}"
  end

  def flag
    @comment.flag!
    CommentMailer.with(comment: @comment, subject: 'Comentario denunciado')
                 .moderation_needed.deliver_now
  end

  protected

  def load_post
    @post = Post.friendly.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit([:content])
  end
end
