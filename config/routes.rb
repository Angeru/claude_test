Rails.application.routes.draw do
  # User registration
  resources :users, only: [:new, :create]
  get "/signup", to: "users#new", as: :signup

  # Sessions (Login/Logout)
  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # Password reset
  resources :password_resets, only: [:new, :create, :edit, :update]

  # Dashboard
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # Campaigns (for regular users)
  resources :campaigns, only: [:index, :show] do
    member do
      post :subscribe
      delete :unsubscribe
    end
    collection do
      get :my_campaigns
    end
  end

  # Admin backoffice
  namespace :admin do
    resources :users
    resources :campaigns do
      member do
        get :manage_subscriptions
        patch :update_subscriptions
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "sessions#new"
end
