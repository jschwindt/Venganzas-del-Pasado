class UsersController < ApplicationController
  before_action :load_resource, except: :index
  load_and_authorize_resource

  # TODO: Cambiar a UsersController
  def sign_in
    render :layout => 'lean'
  end

  def show
    if params[:id] != @user.to_param
      return redirect_to url_for(params.merge(:id => @user.to_param)), :status => :moved_permanently
    end

    comments_collection = @user.comments.visible_by(current_user).lifo
    @objects = comments_collection.page(params[:page]).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

  def comments
    comments_collection = @user.comments.visible_by(current_user).lifo
    @objects = comments_collection.page(params[:page]).per(VenganzasDelPasado::Application.config.comments_per_page)

    render :show
  end

  def contributions
    @objects = @user.contributions.published.
              page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)

    render :show
  end

  def likes
    comments_collection = (Comment.all_liked_by @user).visible_by(current_user).lifo
    @objects = comments_collection.page(params[:page]).per(VenganzasDelPasado::Application.config.comments_per_page)

    render :show
  end

  def dislikes
    comments_collection = (Comment.all_disliked_by @user).visible_by(current_user).lifo
    @objects = comments_collection.page(params[:page]).per(VenganzasDelPasado::Application.config.comments_per_page)

    render :show
  end

  protected

  def load_resource
    @user = User.friendly.find(params[:id])
  end

end
