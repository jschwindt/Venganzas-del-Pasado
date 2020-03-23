Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :users do
    post '/users/auth/:provider' => 'users/omniauth_callbacks#passthru', :as => :user_omniauth
  end

  root to: 'home#index'
end
