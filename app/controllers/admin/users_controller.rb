module Admin
  class UsersController < BaseController
    before_action :load_collection, only: :index
    before_action :load_resource, except: :index
    authorize_resource
    has_scope :lifo, type: :boolean, default: true

    protected

    def verify_admin
      render '403', status: 403 unless current_user.can? :manage, User
    end

    def load_collection
      @users = apply_scopes User
    end

    def load_resource
      @user = User.friendly.find(params[:id])
    end

    def user_params
      params.require(:user).permit(%i[alias karma role])
    end
  end
end
