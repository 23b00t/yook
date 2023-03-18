class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: %i[update destroy]

  def create
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)
    @recipe = Recipe.find(params[:recipe_id])
    @recipe_ingredient.recipe = @recipe
    if @recipe_ingredient.save
      redirect_to ingredients_path, notice: "Added Ingredient"
    else
      redirect_to ingredients_path, alert: "Error"
    end
  end

  def index
    @recipe_ingredients = RecipeIngredient.all.select { |i| i.recipe_id = params[:recipe_id] }
  end

  def update
    @recipe = Recipe.find(session[:recipe_id])
    @ingredients = []
    if @recipe_ingredient.update(recipe_ingredient_params)
      redirect_to ingredients_path, notice: "Updated successfully"
    else
      render 'ingredients/index', status: :unprocessable_entity
    end
  end

  def destroy
    @recipe_ingredient.destroy
    redirect_to ingredients_path, status: :see_other
  end

  private

  def set_recipe_ingredient
    @recipe_ingredient = RecipeIngredient.find(params[:id])
  end

  def recipe_ingredient_params
    params.require("recipe_ingredient").permit(:quantity, :measurement, :ingredient_id)
  end
end
