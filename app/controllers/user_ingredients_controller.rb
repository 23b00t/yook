require "pry-byebug"
class UserIngredientsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_user_ingredient, only: %i[update destroy]

  def index
    UserIngredient.all.each do |ingredient|
      convert(ingredient)
      ingredient.destroy if ingredient.quantity.zero?
    end
    @user_ingredients = (UserIngredient.all.select { |i| i.favorited? && i.quantity.positive? && i.user == current_user }).sort
    @user_ingredients += (UserIngredient.all.select { |i| not(i.favorited?) && i.quantity.positive? && i.user == current_user }).sort
    @user_ingredients.each do |user_ingredient|
      next if %w[cup unit quart gallon pint].include? user_ingredient.measurement

      user_ingredient.measurement = Unit.new(user_ingredient.measurement).units
    rescue ArgumentError
      user_ingredient.measurement = "g"
    end
    @new_ingredient = UserIngredient.new
  end

  def update
    if @ingredient.update(user_ingredient_params)
      convert(@ingredient)
      referring_url = request.referrer
      respond_to do |format|
        if referring_url.end_with?('cooked')
          id = referring_url.match(%r{(\d+)/(cooked)$})
          format.html { redirect_to cooked_recipe_path(id[1]) }
        else
          format.html { redirect_to user_ingredients_path }
          format.text { render partial: "user_ingredient_item", locals: { ingredient: @ingredient, notice: "Updated successfully" }, formats: [:html] }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to user_ingredients_path }
        format.text { render partial: "user_ingredient_item", locals: { ingredient: set_user_ingredient, notice: "quantity cant be lower than 0" }, formats: [:html] }
      end
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
