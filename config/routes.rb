Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :members, only: [:index, :show, :new, :create] do
    member do
      get 'search'
    end
  end

  resources :friendships, only: [:new, :create]

  root 'members#index'
end
