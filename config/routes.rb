Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'integrations#index'

  resources :configured_services, except: :show do
    resources :data_sources, except: :show do
      member do
        # This is the route for data sources pushing to the app, not for the app
        # itself pushing.
        post 'push'
      end
    end
    resources :data_destinations, except: :show
  end
  resources :integrations, only: [:index, :new, :create, :destroy] do
    collection do
      post 'save_draft'
    end
  end

  namespace :oauth do
    get :google
  end
end
