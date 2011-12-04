module Admin
  class BaseController < InheritedResources::Base
    before_filter :authenticate_user!

  end
end