Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#index'

  resources :users, except: [:destroy]
  resources :questions, except: [:show, :new, :index]
  resources :sessions, only: [:new, :create, :destroy]

  get 'sign_up' => 'users#new'
  get 'log_in' => 'sessions#new'
  get 'log_out' => 'sessions#destroy'
end
