require "pry-byebug"
class UserIngredientsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_user_ingredient, only: %i[update destroy]

  def index
    UserIngredient.all.each { |ingredient| convert(ingredient) }
    @user_ingredients = (UserIngredient.all.select { |i| i.quantity.positive? && i.user == current_user }).sort
    @user_ingredients.each do |user_ingredient|
      next if %w[cup unit quart gallon pint].include? user_ingredient.measurement

      user_ingredient.measurement = Unit.new(user_ingredient.measurement).units
    rescue ArgumentError
      user_ingredient.measurement = "g"
    end
    @new_ingredient = UserIngredient.new
  end

  def update
    raise
    @ingredient.update(user_ingredient_params)
    convert(@ingredient)
    referring_url = request.referrer
    if referring_url.end_with?('cooked')
      id = referring_url.match(%r{(\d+)/(cooked)$})
      redirect_to cooked_recipe_path(id[1])
    else
      redirect_to user_ingredients_path
    end
  end

  def create
    @ingredient = Ingredient.new(name: params[:user_ingredient][:ingredient_id])
    @ingredient = Ingredient.find_by(name: params[:user_ingredient][:ingredient_id]) unless @ingredient.save

    @new_users_ingredient = UserIngredient.new(user_ingredient_params)
    @new_users_ingredient.user_id = current_user.id
    @new_users_ingredient.ingredient_id = @ingredient.id
    respond_to do |format|
      if @new_users_ingredient.save
        format.html { redirect_to user_ingredients_path }
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
    redirect_to user_ingredients_path
  end


  private

  def user_ingredient_params
    params.require(:user_ingredient).permit(:measurement, :quantity, :favorited)
  end

  def set_user_ingredient
    @ingredient = UserIngredient.find(params[:id])
  end

  #automaticly converts measurment 1000g = 1kg and so on
  def convert(ingredient)
    if ingredient.quantity >= 1000
      case ingredient.measurement.downcase
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
