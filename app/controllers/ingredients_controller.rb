class IngredientsController < ApplicationController
  def index
    @recipe = Recipe.find(session[:recipe_id])
    if params[:query].present?
      @ingredients = Ingredient.search_by_name(params[:query])
    else
      @ingredients = []
    end
  end
end
