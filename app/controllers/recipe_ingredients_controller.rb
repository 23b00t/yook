require 'ruby-units'

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: %i[update destroy]
  before_action :set_recipe, only: %i[create index update]

  def create
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)
    @recipe_ingredient.recipe = @recipe
    @recipe_ingredient.ingredient = Ingredient.where(name: recipe_ingredient_params[:ingredient_id]).first
    if @recipe_ingredient.save
      redirect_to recipe_recipe_ingredients_path, notice: "Added Ingredient"
    else
      redirect_to recipe_recipe_ingredients_path, alert: "Error"
    end
  end

  def index
    @recipe_ingredients = @recipe.recipe_ingredients
    @recipe_ingredients.each do |recipe|
      next if %w[cup unit quart gallon pint].include? recipe.measurement

      recipe.measurement = Unit.new(recipe.measurement).units
    rescue ArgumentError
      recipe.measurement = "g"
    end
    @ingredient = RecipeIngredient.new
    # raise
  end

  def update
    if @recipe_ingredient.update(recipe_ingredient_params)
      redirect_to recipe_recipe_ingredients_path, notice: "Updated successfully"
    else
      render 'ingredients/index', status: :unprocessable_entity
    end
  end

  def destroy
    @recipe_ingredient.destroy
    redirect_to recipe_recipe_ingredients_path, status: :see_other
  end

  private

  def set_recipe_ingredient
    @recipe_ingredient = RecipeIngredient.find(params[:id])
  end

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def recipe_ingredient_params
    params.require("recipe_ingredient").permit(:quantity, :measurement, :ingredient_id)
  end
end
