Rails.application.routes.draw do

  get "search(/:what)", :action => :index, :controller => :search, :as => :search

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :users do
    post '/users/auth/:provider' => 'users/omniauth_callbacks#passthru', :as => :user_omniauth
  end

  get 'posts/:year(/:month(/:day))' => 'posts#archive', :as => :posts_archive, :constraints => {
    :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
  }

  get 'contributions(/page/:page)' => 'posts#contributions', :as => :contributions

  resources :posts, :only => [:index, :show, :new, :create] do
    get 'page/:page', :action => :index, :on => :collection   # SEO friendly pagination for posts
    get 'page/:page', :action => :show, :on => :member        # SEO friendly pag. for post's comments
    resources :comments, :only => [:create, :show]
    resources :audios, :only => :show
  end

  resources :comments, :only => [] do
    member do
      post 'flag'
      post 'like'
      post 'dislike'
      get 'opinions'
    end
  end

  resources :users, :only => :show do
    get 'comments(/page/:page)', :action => :comments, :on => :member, :as => :comments
    get 'contributions(/page/:page)', :action => :contributions, :on => :member, :as => :contributions
    get 'likes(/page/:page)', :action => :likes, :on => :member, :as => :likes
    get 'dislikes(/page/:page)', :action => :dislikes, :on => :member, :as => :dislikes
  end

  resources :articles, :only => :show
  resources :torrents, :only => :index

  namespace :admin do
    get '/' => 'base#dashboard', :as => :dashboard

    resources :articles, :except => :show
    resources :users, :only => [:index, :edit, :update]

    resources :comments do
      member do
        get 'approve'
        get 'trash'
      end
    end

    resources :posts do
      member do
        get 'approve_contribution'
      end
    end
  end

  root :to => 'home#index'

  get '*path(.:format)' => "redirects#index"

end
