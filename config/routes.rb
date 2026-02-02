Rails.application.routes.draw do
  get "registrations/new"
  get "registrations/create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  post "/signup", to: "users#create"
  post "/login", to: "users#login"

  get "/users", to: "users#index"

  get "/users/:id", to: "users#show"

  post "/users", to: "users#create"

  patch "/users/:id", to: "users#update"

  delete "/users/:id", to: "users#destroy"


  get "/tickets", to: "tickets#index"

  get "/tickets/:id", to: "tickets#show"

  post "/tickets", to: "tickets#create"

  patch "/tickets/:id", to: "tickets#update"

  delete "/tickets/:id", to: "tickets#destroy"



  # resources :users do
  #   resources :tickets

  # end
  # resources :users
end
