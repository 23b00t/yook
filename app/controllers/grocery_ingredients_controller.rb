require "#{Rails.root}/lib/flash_messages"

class GroceryIngredientsController < ApplicationController
  # adjust_measurement and substract_ingredients methods
  include UnitHelpers
  before_action :set_grocery_ingredient, only: %i[update destroy]

  def index
    @groceries = (GroceryIngredient.all.select { |i| i.quantity && i.user == current_user }).sort
    @groceries.delete_if { |grocery| grocery.quantity.zero? }
    @new_ingredient = GroceryIngredient.new
  end

  def update
    respond_to do |format|
      if @ingredient.update(grocery_ingredient_params)
        convert(@ingredient)
        format.html { redirect_to grocery_ingredients_path }
        format.text { render partial: "grocery_ingredient_item", locals: { ingredient: @ingredient, notice: FlashMessages.success }, formats: [:html] }
      else
        format.html { redirect_to grocery_ingredients_path, notice: FlashMessages.negative_quantity_error }
        format.text { render partial: "grocery_ingredient_item", locals: { ingredient: set_grocery_ingredient, notice: FlashMessages.negative_quantity_error }, formats: [:html] }
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
      @grocery_item.save ? format.html { redirect_to grocery_ingredients_path } : format.html
      format.json
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
    user_ingredient = UserIngredient.find_by(ingredient_id:)
    if user_ingredient.present?
      begin
        new_measurement = sum_ingredients(grocery_ingredient, user_ingredient)
        quantity = new_measurement.scalar
        user_ingredient.update(quantity:)
      rescue ArgumentError
        flash.now[:alert] = FlashMessages.measurement_error(grocery_ingredient, user_ingredient)
      end
    else
      UserIngredient.create(quantity: grocery_ingredient.quantity, measurement: grocery_ingredient.measurement, ingredient_id:, user: current_user)
    end
    grocery_ingredient.delete
    if flash[:alert].present?
      redirect_to user_ingredients_path, alert: flash[:alert]
    else
      redirect_to grocery_ingredients_path, notice: FlashMessages.purchased
    end
  end

  private

  def set_grocery_ingredient
    @ingredient = GroceryIngredient.find(params[:id])
  end

  def grocery_ingredient_params
    params.require(:grocery_ingredient).permit(:name, :measurement, :quantity)
  end

  def convert(ingredient)
    return unless ingredient.quantity >= 1000 || %w[g ml mg].include?(ingredient.measurement)

    ingredient.quantity /= 1000
    case ingredient.measurement
    when "g" then ingredient.measurement = "kg"
    when "mg" then ingredient.measurement = "g"
    when "ml" then ingredient.measurement = "l"
    end
    ingredient.save
  end
end
