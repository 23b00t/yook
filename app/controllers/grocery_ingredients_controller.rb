require 'ruby-units'

class GroceryIngredientsController < ApplicationController
  before_action :set_grocery_ingredient, only: %i[update destroy]

  def index
    @groceries = (GroceryIngredient.all.select { |i| i.quantity && i.user == current_user }).sort
    @groceries.each do |grocery|
      grocery.destroy if grocery.quantity.zero?
      next if %w[cup unit quart gallon pint].include? grocery.measurement
      begin
        grocery.measurement = Unit.new(grocery.measurement).units
      rescue
        #error
      end
    rescue ArgumentError
      grocery.measurement = "g"
    end
    @new_ingredient = GroceryIngredient.new
  end

  def update
    respond_to do |format|
      if @ingredient.update(grocery_ingredient_params)
        convert(@ingredient)
        format.html { redirect_to grocery_ingredients_path }
        format.text { render partial: "grocery_ingredient_item", locals: { ingredient: @ingredient, notice: "Updated successfully" }, formats: [:html] }
      else
        format.html { redirect_to grocery_ingredients_path, notice: "quantity cant be lower than 0" }
        format.text { render partial: "grocery_ingredient_item", locals: { ingredient: set_grocery_ingredient, notice: "quantity cant be lower than 0" }, formats: [:html] }
      end
    end
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
    purchased = params[:grocery_ingredient_id]
    grocery_ingredient = GroceryIngredient.find(purchased)
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
    redirect_to grocery_ingredients_path(notice: "Ingredient was purchased! Check your Inventory!")
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
      when "g"
        ingredient.quantity /= 1000
        ingredient.measurement = "kg"
        ingredient.save
      when "mg"
        ingredient.quantity /= 1000
        ingredient.measurement = "g"
        ingredient.save
      when "ml"
        ingredient.quantity /= 1000
        ingredient.measurement = "l"
        ingredient.save
      end
    end
  end
end
