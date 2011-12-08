module Admin
  class PostsController < BaseController
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true
  end
end
