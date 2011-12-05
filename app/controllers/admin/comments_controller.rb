# encoding: utf-8

module Admin
  class CommentsController < BaseController
    has_scope :pending, :type => :boolean
  end
end
