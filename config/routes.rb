Rails.application.routes.draw do
  devise_for :users

  root to: 'recipes#index'

  resources :recipes do
    resources :recipe_ingredients, only: :create
    member do
      get 'edit_description'
      patch 'update_description'
      get 'cooked'
      get 'create_grocery_list'
    end
  end

  resources :recipe_ingredients, only: :update
  resources :ingredients, only: :index

  resources :user_ingredients

  resources :grocery_ingredients, only: %i[index create update destroy]
end
