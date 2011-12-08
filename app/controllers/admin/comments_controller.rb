# encoding: utf-8

module Admin
  class CommentsController < BaseController
    has_scope :has_status
    has_scope :lifo, :type => :boolean, :default => true

    def approve
      @comment = Comment.find params[:id]
      @comment.status = 'approved'
      @comment.save!
      redirect_to collection_url
    end

    def trash
      @comment = Comment.find params[:id]
      @comment.status = 'deleted'
      @comment.save!
      redirect_to collection_url
    end

  end
end
