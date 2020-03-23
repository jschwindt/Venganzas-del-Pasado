# encoding: utf-8

class AudiosController < ApplicationController
  load_and_authorize_resource :post
  load_and_authorize_resource :audio, :through => :post

  def show
    render :layout => 'popup'
  end
end
