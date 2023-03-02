Rails.application.routes.draw do
  devise_for :users
  # root to: "pages#home"
  root to: 'recipes#index'

  resources :recipes do
    resources :recipe_ingredients, only: :create
  end

  resources :ingredients, only: :index

  resources :user_ingredients
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
