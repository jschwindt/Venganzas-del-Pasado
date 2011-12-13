module Admin
  class UsersController < BaseController
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    def update
      @user = User.find(params[:id])
      @user.role = params[:user][:role]
      super
    end

    private

    def verify_admin
      unless current_user.can? :manage, User
        render '403', :status => 403
      end
    end

  end
end
