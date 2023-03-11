require "pry-byebug"
class UserIngredientsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_user_ingredient, only: %i[update destroy]

  def index
    UserIngredient.all.each { |ingredient| convert(ingredient) }
    @user_ingredients = UserIngredient.all.select { |i| i.quantity.positive? && i.favorited && i.user_id = current_user.id }
    @user_ingredients += UserIngredient.all.select { |i| i.quantity.positive? && !i.favorited && i.user_id = current_user.id }
    @new_ingredient = UserIngredient.new
  end

  def update
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
    @ingredient = Ingredient.find_by(name: params[:user_ingredient][:ingredient_id].downcase.capitalize)
    if @ingredient
      if UserIngredient.find_by(user_id: @ingredient.id).nil?
        @new_users_ingredient = UserIngredient.new(user_ingredient_params)
        @new_users_ingredient.ingredient_id = @ingredient.id
        @new_users_ingredient.user_id = current_user.id
        @new_users_ingredient.save
      else
        @anchor_user = UserIngredient.find_by(user_id: @ingredient.id)
        redirect_to user_ingredients_path(@anchor_user, anchor: dom_id(@employee))
      end
      redirect_to user_ingredients_path
    else
      redirect_to user_ingredients_path, alert: "Something went wrong!"
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
