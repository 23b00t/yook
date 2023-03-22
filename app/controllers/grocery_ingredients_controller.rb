require 'ruby-units'

class GroceryIngredientsController < ApplicationController
  before_action :set_grocery_ingredient, only: %i[update destroy]

  def index
    @groceries = (GroceryIngredient.all.select { |i| i.quantity && i.user == current_user }).sort
    @groceries.each do |grocery|
      next if %w[cup unit quart gallon pint].include? grocery.measurement

      grocery.measurement = Unit.new(grocery.measurement).units
    rescue ArgumentError
      grocery.measurement = "g"
    end
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
        format.html
        format.json
      end
    end
  end

  def destroy
    @ingredient.destroy
    redirect_to grocery_ingredients_path
  end

  def purchased
    purchased = params[:grocery_ingredient_ids]
    purchased.each do |grocery_ingredient_id|
      grocery_ingredient = GroceryIngredient.find(grocery_ingredient_id)
      ingredient_id = grocery_ingredient.ingredient_id
      user_ingredient = UserIngredient.where(ingredient_id:).first
      if user_ingredient.present?
        unit1 = Unit.new("#{grocery_ingredient.quantity} #{grocery_ingredient.measurement}")
        unit2 = Unit.new("#{user_ingredient.quantity} #{user_ingredient.measurement}")
        begin
          unit3 = (unit1 + unit2).to(user_ingredient.measurement).round(4)
        rescue ArgumentError
          flash.now[:alert] = "Measurement is not compatible"
        end
        quantity = unit3.scalar
        user_ingredient.update(quantity:)
      else
        UserIngredient.create(quantity: grocery_ingredient.quantity, measurement: grocery_ingredient.measurement, ingredient_id:, user: current_user)
      end
      grocery_ingredient.delete
    end
    redirect_to user_ingredients_path
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
