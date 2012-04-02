VenganzasDelPasado::Application.routes.draw do

  get "search(/:what)", :action => :index, :controller => :search, :as => :search

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :users do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru', :as => :user_omniauth
  end

  get 'posts/:year(/:month(/:day))' => 'posts#archive', :as => :posts_archive, :constraints => {
    :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
  }
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
    end
  end

  resources :users, :only => :show do
    get 'page/:page', :action => :show, :on => :member        # SEO friendly pag. for user's comments
  end
  resources :articles, :only => :show
  resources :torrents, :only => :index

  namespace :admin do
    match '/' => 'base#dashboard', :as => :dashboard
    resources :comments do
      member do
        get 'approve'
        get 'trash'
      end
    end
    resources :articles
    resources :users, :only => [:index, :edit, :update]
    resources :posts do
      member do
        get 'approve_contribution'
      end
    end
  end

  get '/switch_player', :controller => :home, :action => :switch_player

  root :to => 'home#index'

  match '*path(.:format)' => "redirects#index"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
