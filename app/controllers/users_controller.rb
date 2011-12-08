class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = @users.active.lifo.page(params[:page]).per(5)
  end

  def show
  end

end
