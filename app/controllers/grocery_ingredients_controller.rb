require "#{Rails.root}/lib/flash_messages"

class GroceryIngredientsController < ApplicationController
  # adjust_measurement and sum_ingredients methods
  include UnitHelpers
  before_action :set_grocery_ingredient, only: %i[update destroy]

  def index
    @groceries = (GroceryIngredient.all.select { |i| i.user == current_user }).sort
    @groceries.delete_if { |grocery| grocery.quantity.zero? }
    @new_ingredient = GroceryIngredient.new

    respond_to do |format|
      format.html
      format.text { render partial: "grocery_list_ingredients", formats: [:html], locals: { ingredients: @groceries } }
    end
  end

  def update
    respond_to do |format|
      if ingredient_updated?
        format.html { redirect_to grocery_ingredients_path }
        format.text { render_updated_ingredient }
      else
        format.html { redirect_to grocery_ingredients_path, notice: FlashMessages.negative_quantity_error }
        format.text { render_error_ingredient }
      end
    end
  end

  def create
    ingredient = Ingredient.new(name: params[:grocery_ingredient][:ingredient_id])
    ingredient = Ingredient.find_by(name: params[:grocery_ingredient][:ingredient_id]) unless ingredient.save

    @grocery_item = GroceryIngredient.new(grocery_ingredient_params)
    @grocery_item.user_id = current_user.id
    @grocery_item.ingredient_id = ingredient.id

    respond_to do |format|
      @grocery_item.save ? format.html { redirect_to grocery_ingredients_path } : format.html
      format.json
    end
  end

  def destroy
    @grocery_ingredient.destroy
    redirect_to grocery_ingredients_path
  end

  def purchased
    purchased_ids = params[:grocery_ingredient_ids]

    purchased_ids.each do |purchased_id|
      grocery_ingredient = GroceryIngredient.find(purchased_id)
      user_ingredient = UserIngredient.find_by(ingredient_id: grocery_ingredient.ingredient_id)

      sum_ingredients(grocery_ingredient, user_ingredient) if user_ingredient.present?
      user_ingredient.update(quantity: @quantity) if @quantity.present? && user_ingredient.present?

      create_user_ingredient(grocery_ingredient) unless user_ingredient

      grocery_ingredient.delete
    end

    # return redirect_to user_ingredients_path, alert: @alert_msg if @alert_msg.present?

    # redirect_to grocery_ingredients_path, notice: FlashMessages.purchased
    if @alert_msg.present?
      render json: { alert: @alert_msg }
    else
      render json: { notice: FlashMessages.purchased }
    end
  end

  private

  def set_grocery_ingredient
    @grocery_ingredient = GroceryIngredient.find(params[:id])
  end

  def grocery_ingredient_params
    params.require(:grocery_ingredient).permit(:name, :measurement, :quantity)
  end

  def convert(ingredient)
    return unless ingredient.quantity >= 1000 || %w[g ml mg].include?(ingredient.measurement)

    ingredient.quantity /= 1000
    measurement_map = { "g" => "kg", "mg" => "g", "ml" => "l" }
    ingredient.measurement = measurement_map[ingredient.measurement]
    ingredient.save
  end

  def ingredient_updated?
    if @grocery_ingredient.update(grocery_ingredient_params)
      convert(@grocery_ingredient)
      true
    else
      false
    end
  end

  def render_updated_ingredient
    render partial: "grocery_ingredient_item",
           locals: { ingredient: @grocery_ingredient, notice: FlashMessages.success },
           formats: [:html]
  end

  def render_error_ingredient
    render partial: "grocery_ingredient_item",
           locals: { ingredient: set_grocery_ingredient, notice: FlashMessages.negative_quantity_error },
           formats: [:html]
  end

  def create_user_ingredient(grocery_ingredient)
    UserIngredient.create(quantity: grocery_ingredient.quantity,
                          measurement: grocery_ingredient.measurement,
                          ingredient_id: grocery_ingredient.ingredient_id,
                          user: current_user)
  end
end
