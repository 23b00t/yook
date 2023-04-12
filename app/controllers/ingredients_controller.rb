class IngredientsController < ApplicationController
  def index
    @recipe = Recipe.find(session[:recipe_id])
    @ingredients = params[:query].present? ? Ingredient.search_by_name(params[:query]) : []
  end
end
