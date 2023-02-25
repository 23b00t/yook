Rails.application.routes.draw do
  devise_for :users
  # root to: "pages#home"
  root to: 'recipes#index'

  resources :recipes
  resources :user_ingredients
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
