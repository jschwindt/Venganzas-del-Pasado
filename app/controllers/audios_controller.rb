class AudiosController < ApplicationController
  before_action :load_post, only: [:show]
  load_and_authorize_resource :audio, through: :post

  def show
    render layout: 'popup'
  end

  protected

  def load_post
    @post = Post.friendly.find(params[:post_id])
  end
end
