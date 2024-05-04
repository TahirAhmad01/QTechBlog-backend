Rails.application.routes.draw do

  scope :api, defaults: { format: :json } do
    scope :v1 do
      devise_for :users, path: 'users', path_names: {
        sign_in: 'login',
        sign_out: 'logout',
        registration: 'signup'
      }, controllers: {
        sessions: 'sessions',
        registrations: 'registrations'
      }
    end
  end

  namespace :api do
    namespace :v1 do
      root to: 'home#index', as: "api_home"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
