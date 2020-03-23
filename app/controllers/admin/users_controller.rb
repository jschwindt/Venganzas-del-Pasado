module Admin
  class UsersController < BaseController
    load_and_authorize_resource
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    private

    def verify_admin
      unless current_user.can? :manage, User
        render '403', :status => 403
      end
    end

  end
end
