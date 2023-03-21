class GroceryIngredientsController < ApplicationController
  before_action :set_grocery_ingredient, only: %i[update destroy]

  def index
    GroceryIngredient.all.each { |ingredient| convert(ingredient) }
    @groceries = (GroceryIngredient.all.select { |i| i.quantity.positive? && i.user == current_user }).sort
    @new_ingredient = GroceryIngredient.new
  end

  def update
    @ingredient.update(grocery_ingredient_params)
    convert(@ingredient)
    redirect_to grocery_ingredients_path
  end

  def create
    @ing = Ingredient.find_by(name: params[:grocery_ingredient][:ingredient_id])

    if @ing
      @grocery_item = GroceryIngredient.new(grocery_ingredient_params)
      @grocery_item.user_id = current_user.id
      @grocery_item.ingredient_id = @ing.id
      @grocery_item.save
      redirect_to grocery_ingredients_path
    else
      redirect_to grocery_ingredients_path, alert: "Something went wrong!"
    end
  end

  def destroy
    @ingredient.destroy
    redirect_to grocery_ingredients_path
  end

  def purchased
    raise
  end

  private

  def set_grocery_ingredient
    @ingredient = GroceryIngredient.find(params[:id])
  end

  def grocery_ingredient_params
    params.require(:grocery_ingredient).permit(:name, :measurement, :quantity)
  end

  #automaticly converts measurment 1000g = 1kg and so on
  def convert(ingredient)
    if ingredient.quantity >= 1000
      case ingredient.measurement
      when "gram"
        ingredient.quantity /= 1000
        ingredient.measurement = "kilogram"
        ingredient.save
      when "milligram"
        ingredient.quantity /= 1000
        ingredient.measurement = "gram"
        ingredient.save
      when "milliliter"
        ingredient.quantity /= 1000
        ingredient.measurement = "liter"
        ingredient.save
      end
    end
  end
end
