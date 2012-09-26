class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    if params[:id] != @user.to_param
      return redirect_to url_for(params.merge(:id => @user.to_param)), :status => :moved_permanently
    end
    comments_collection = @user.comments.visible_by(current_user).lifo
    @comments = comments_collection.page(params[:page]).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

end