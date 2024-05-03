Rails.application.routes.draw do
  root 'home#index'
  scope :api, defaults: { format: :json } do
    scope :v1 do
      devise_for :users, path: 'users', path_names: {
        sign_in: 'login',
        sign_out: 'logout',
        registration: 'signup'
      }, controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations'
      }
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
