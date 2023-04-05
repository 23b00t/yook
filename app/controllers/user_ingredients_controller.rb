require "pry-byebug"
class UserIngredientsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_user_ingredient, only: %i[update destroy]

  def index
    UserIngredient.all.each do |ingredient|
      convert(ingredient)
      ingredient.destroy if ingredient.quantity.zero?
    end
    @user_ingredients = (UserIngredient.all.select { |i| i.quantity.positive? && i.user == current_user }).sort
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
