class RecipeIngredientsController < ApplicationController
  def create
    @recipe_ingredient = RecipeIngredient.new
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)
    if @recipe_ingredient.save
      redirect_to ingredients_path, notice: "Added Ingredient"
    else
      redirect_to ingredients_path, alert: "Error"
    end
  end

  private

  def recipe_ingredient_params
    params.permit(:quantity, :measurment, :recipe_id, :ingredient_id)
  end
end
