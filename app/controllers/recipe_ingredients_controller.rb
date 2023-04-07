require "#{Rails.root}/lib/flash_messages"

class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: %i[update destroy]
  before_action :set_recipe, only: %i[create index update]

  def create
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)
    @recipe_ingredient.recipe = @recipe
    @recipe_ingredient.ingredient = Ingredient.find_or_create_by(name: recipe_ingredient_params[:ingredient_id])
    respond_to do |format|
      if @recipe_ingredient.save
        format.html { redirect_to user_ingredients_path }
      else
        flash[:alert] = FlashMessages.doubble_entry
        format.html { redirect_to user_ingredients_path(anchor: UserIngredient.find_by(user_id: @ingredient.id)) }
      end
      format.json
    end
  end

  def index
    @recipe_ingredients = @recipe.recipe_ingredients
    @ingredient = RecipeIngredient.new
  end

  def update
    respond_to do |format|
      if @recipe_ingredient.update(recipe_ingredient_params)
        convert(@recipe_ingredient)
        format.html { redirect_to recipe_recipe_ingredients_path }
        format.text { render_updated_ingredient }
      else
        flash[:alert] = FlashMessages.negative_quantity_error
        format.html { redirect_to recip_recipe_ingredients_path }
        format.text { render_error_ingredient }
      end
    end
  end

  def destroy
    @recipe_ingredient.destroy
    redirect_to recipe_recipe_ingredients_path(@recipe), notice: FlashMessages.recipe_ingredient_deleted
  end

  private

  def set_recipe_ingredient
    @recipe_ingredient = RecipeIngredient.find(params[:id])
  end

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def recipe_ingredient_params
    params.require(:recipe_ingredient).permit(:name, :measurement, :quantity)
  end

  def convert(ingredient)
    return unless ingredient.quantity >= 1000 || %w[g ml mg].include?(ingredient.measurement)

    ingredient.quantity /= 1000
    measurement_map = { "g" => "kg", "mg" => "g", "ml" => "l" }
    ingredient.measurement = measurement_map[ingredient.measurement]
    ingredient.save
  end


  def render_updated_ingredient
    render partial: "recipe_ingredient_item",
           locals: { ingredient: @recipe_ingredient, notice: FlashMessages.success },
           formats: [:html]
  end

  def render_error_ingredient
    render partial: "recipe_ingredient_item",
           locals: { ingredient: set_recipe_ingredient, notice: FlashMessages.negative_quantity_error },
           formats: [:html]
  end
end
