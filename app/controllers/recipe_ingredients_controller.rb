require 'ruby-units'

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: %i[update destroy]
  before_action :set_recipe, only: %i[create index update]

  def create
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)
    @recipe_ingredient.recipe = @recipe
    @recipe_ingredient.ingredient = Ingredient.where(name: recipe_ingredient_params[:ingredient_id]).first
    respond_to do |format|
      if @recipe_ingredient.save
        format.html { redirect_to user_ingredients_path }
        format.json
      else
        @anchor_user = UserIngredient.find_by(user_id: @ingredient.id)
        format.html { redirect_to user_ingredients_path(anchor: @anchor_user, alert: "You already have this ingredient in Fridge! please change the quantity manualy!")}
        format.json
      end
    end
  end

  def index
    @recipe_ingredients = @recipe.recipe_ingredients
    @ingredient = RecipeIngredient.new
  end

  def update
    respond_to do |format|
      if @recipe_ingredient.update(recipe_ingredient_params)
        format.html { redirect_to recipe_recipe_ingredients_path }
        format.text { render partial: "recipe_ingredient_item", locals: { ingredient: @recipe_ingredient, notice: "Updated successfully" }, formats: [:html] }
      else
        format.html { redirect_to recip_recipe_ingredients_path, notice: "quantity cant be lower than 0" }
        format.text { render partial: "recipe_ingredient_item", locals: { ingredient: set_recipe_ingredient, notice: "quantity cant be lower than 0" }, formats: [:html] }
      end
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
    params.require("recipe_ingredient").permit(:quantity, :measurement, :ingredient_id, :comment)
  end
end
