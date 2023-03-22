class GroceryIngredientsController < ApplicationController
  before_action :set_grocery_ingredient, only: %i[update destroy]

  def index
    GroceryIngredient.all.each { |ingredient| }
    @groceries = (GroceryIngredient.all.select { |i| i.quantity.positive? && i.user == current_user }).sort
    @new_ingredient = GroceryIngredient.new
  end

  def update
    @ingredient.update(grocery_ingredient_params)
    #convert(@ingredient)
    redirect_to grocery_ingredients_path
  end

  def create
    @ing = Ingredient.new(name: params[:grocery_ingredient][:ingredient_id])
    @ing = Ingredient.find_by(name: params[:grocery_ingredient][:ingredient_id]) unless @ing.save

    @grocery_item = GroceryIngredient.new(grocery_ingredient_params)
    @grocery_item.user_id = current_user.id
    @grocery_item.ingredient_id = @ing.id

    respond_to do |format|
      if @grocery_item.save
        format.html { redirect_to grocery_ingredients_path }
        format.json
      else
        @anchor_user = UserIngredient.find_by(user_id: @ingredient.id)
        format.html { redirect_to user_ingredients_path(anchor: @anchor_user, alert: "You already have this ingredient in Fridge! please change the quantity manualy!")}
        format.json
      end
    end
  end

  def destroy
    @ingredient.destroy
    redirect_to grocery_ingredients_path
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
