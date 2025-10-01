Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "search(/:what)", action: :index, controller: :search, as: :search

  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  get "posts/:year(/:month(/:day))" => "posts#archive", as: :posts_archive, constraints: {
    year: /\d{4}/, month: /\d{1,2}/, day: /\d{1,2}/
  }

  get "contributions(/page/:page)" => "posts#contributions", as: :contributions

  resources :posts, only: %i[index show new create] do
    get "page/:page", action: :index, on: :collection   # SEO friendly pagination for posts
    get "page/:page", action: :show, on: :member        # SEO friendly pag. for post's comments
    resources :comments, only: %i[create show]
    resources :audios, only: :show
  end

  resources :comments, only: [] do
    member do
      post "flag"
    end
  end

  resources :users, only: :show do
    get "comments(/page/:page)", action: :comments, on: :member, as: :comments
    get "contributions(/page/:page)", action: :contributions, on: :member, as: :contributions
  end

  resources :articles, only: :show

  namespace :admin do
    get "/" => "base#dashboard", as: :dashboard

    resources :articles, except: :show
    resources :users, only: %i[index edit update]

    resources :comments do
      member do
        get "approve"
        delete "trash"
      end
    end

    resources :posts do
      member do
        get "approve_contribution"
      end
    end

    get "/preview" => "preview#index"
    post "/preview" => "preview#publish", as: :publish
  end

  get "speech_to_text/next" => "speech_to_text#next", as: :speech_to_text_next
  put "speech_to_text/start/:id" => "speech_to_text#start", as: :speech_to_text_start
  put "speech_to_text/update/:id" => "speech_to_text#update", as: :speech_to_text_update

  root to: "home#index"

  get "*path(.:format)" => "redirects#index"
end
