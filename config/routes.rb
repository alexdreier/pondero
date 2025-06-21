Rails.application.routes.draw do
  resources :analytics, only: [:index] do
    collection do
      get :user_analytics
      get :journal_analytics
      get :export
      get :dashboard_data
    end
  end
  resources :themes
  devise_for :users
  
  # LTI routes
  post "lti/launch"
  get "lti/configure"
  get "lti/config", to: "lti#config"
  
  resources :journals do
    resources :sections, except: [:index, :show] do
      collection do
        patch :reorder
      end
    end
    resources :questions, except: [:index, :show] do
      collection do
        patch :reorder
      end
    end
    resources :journal_entries do
      member do
        patch :submit
      end
    end
    collection do
      get :templates
      post :create_from_template
    end
    member do
      patch :publish
      patch :unpublish
      get :export_pdf
      post :copy
      patch :assign_canvas_course
      delete :remove_canvas_assignment
    end
  end
  
  resources :journal_submissions, only: [:show, :create, :update] do
    resources :comments, only: [:create, :destroy]
  end
  
  resources :responses, only: [:create, :update]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Admin routes
  namespace :admin do
    resources :users, except: [:new, :create] do
      collection do
        get :export
      end
    end
  end

  # Dashboard route
  get 'dashboard', to: 'dashboard#index'
  
  # Temporary fix route (remove after use)
  get 'fix_journals', to: 'application#fix_journals'
  
  # Defines the root path route ("/")
  root "dashboard#index"
end
