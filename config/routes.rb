Rails.application.routes.draw do
  root "projects#index"

  resources :projects do
    resources :contracts, only: [ :create, :destroy, :show ] do
      post :rerun, on: :member
    end
    resources :fields, only: [ :create, :destroy ]
    resources :extractions, only: [ :show, :update ]
    get "export", to: "exports#show", as: :export
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
