class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    comments_collection = @user.comments.approved_or_from_user(current_user).fifo
    page = params[:page].present? ?
             params[:page] :
             comments_collection.page.per(VenganzasDelPasado::Application.config.comments_per_page).num_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

end
