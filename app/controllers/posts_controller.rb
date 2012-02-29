# encoding: utf-8

class PostsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => :archive

  def index
    @posts = @posts.published.lifo.page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def show
    comments_collection = @post.comments.visible_by(current_user).fifo
    page = params[:page].present? ?
             params[:page] :
             comments_collection.page.per(VenganzasDelPasado::Application.config.comments_per_page).num_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

  def archive
    authorize! :index, Post
    @posts = Post.published.lifo.
              created_on(params[:year], params[:month], params[:day]).
              page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def new
    @post = Post.new
    @post.media.build
  end

  def create
    @post = Post.new(params[:post])
    @post.status = 'draft'
    @post.created_at += 4.hours
    if @post.save
      redirect_to new_post_url, :notice => "El archivo se subió con éxito y pronto será revisado y, si corresponde, aprobado."
    else
      render 'new'
    end
  end
end
