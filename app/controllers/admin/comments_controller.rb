# encoding: utf-8

module Admin
  class CommentsController < BaseController
    has_scope :pending, :type => :boolean
    has_scope :deleted, :type => :boolean
    has_scope :lifo, :type => :boolean, :default => true

    def approve
    end

  end
end
