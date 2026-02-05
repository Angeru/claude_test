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
  resources :campaigns, only: [:index, :show, :new, :create] do
    resources :campaign_rounds, path: 'rounds' do
      resources :matchups do
        resources :battle_rosters, path: 'battle', only: [:show, :create, :destroy] do
          member do
            patch :toggle
          end
          resources :battle_roster_units, path: 'units', only: [] do
            member do
              patch :wound
              patch :heal
            end
          end
        end
      end
    end
    member do
      post :subscribe
      delete :unsubscribe
      get :manage_warbands
    end
    collection do
      get :my_campaigns
    end
  end

  # Warbands
  resources :warbands do
    resources :warband_members, path: 'members' do
      resources :warband_equipments, path: 'equipment'
      resources :warband_skills, path: 'skills'
    end
    member do
      patch :remove_from_campaign
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
    resources :warbands do
      resources :warband_members, path: 'members' do
        resources :warband_equipments, path: 'equipment'
        resources :warband_skills, path: 'skills'
      end
      member do
        patch :remove_from_campaign
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "home#index"
end
