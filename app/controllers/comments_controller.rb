class CommentsController < ApplicationController
  before_action :load_post, only: %i[create show]
  load_and_authorize_resource :comment, only: %i[flag]
  load_and_authorize_resource :comment, through: :post, only: %i[create show]

  def index
    @comments = Comment.visible_by(current_user).lifo.limit(VenganzasDelPasado::Application.config.comments_per_page)
  end

  def show
    p @comment
  end

  def create
    @comment = @post.comments.new(params[:comment]).publish_as(current_user, request)
    @comment.save

    if @comment.pending?
      flash[:warning] = 'Tu comentario se ha guardado, y está pendiente de aprobación.'
      CommentMailer.moderation_needed(@comment, 'Comentario para moderar').deliver_now
    else
      flash[:notice] = 'Tu comentario ha sido publicado.'
    end

    flash[:created_comment_id] = @comment.id

    redirect_to "#{post_path(@post)}#comment-#{@comment.id}"
  end

  def flag
    @comment.flag!
    CommentMailer.moderation_needed(@comment, 'Comentario denunciado').deliver_now
  end

  protected

  def load_post
    @post = Post.friendly.find(params[:post_id])
  end

end
