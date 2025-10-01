class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    if params[:id] != @user.to_param
      return redirect_to user_url(@user), status: :moved_permanently
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
    @objects = @user.contributions.published
                    .page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)

    render :show
  end
end
