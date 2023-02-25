class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[]

  def index
    @recipes = Recipe.all
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :cooking_time, :description, :rating, :difficulty, :serving_size, :cooked, :notes)
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
