Rails.application.routes.draw do
  devise_for :users

  root to: 'recipes#index'

  resources :recipes do
    resources :recipe_ingredients, only: :create
    get 'edit_description', on: :member
    patch 'update_description', on: :member
    get 'update_user_ingredients', on: :member
  end

  resources :ingredients, only: :index

  resources :user_ingredients

  resources :grocery_ingredients, only: %i[index create update destroy]
end
