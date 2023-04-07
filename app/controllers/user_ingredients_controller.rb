class UserIngredientsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_user_ingredient, only: %i[update destroy]
  before_action :load_flash_messages, only: %i[update create]

  def index
    UserIngredient.all.each do |ingredient|
      convert(ingredient)
      ingredient.destroy if ingredient.quantity.zero?
    end
    @user_ingredients = UserIngredient.where(quantity: 1..Float::INFINITY, user: current_user).sort
    @new_ingredient = UserIngredient.new
  end

  def update
    if @ingredient.update(user_ingredient_params)
      convert(@ingredient)
      redirect_to redirect_path, notice: flash_messages[:success]
    else
      redirect_to user_ingredients_path, alert: flash_messages[:negative_quantity_error]
    end
  end

  def create
    @ingredient = Ingredient.find_or_create_by(name: params[:user_ingredient][:ingredient_id])
    @new_users_ingredient = UserIngredient.new(user_ingredient_params)
    @new_users_ingredient.user_id = current_user.id
    @new_users_ingredient.ingredient_id = @ingredient.id
    if @new_users_ingredient.save
      redirect_to user_ingredients_path, notice: flash_messages[:success]
    else
      redirect_to user_ingredients_path(anchor: @new_users_ingredient.user_id), alert: flash_messages[:double_entry]
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
    measurement_map = { "g" => "kg", "mg" => "g", "ml" => "l" }
    ingredient.measurement = measurement_map[ingredient.measurement]
    ingredient.save
  end

  def redirect_path
    if request.referrer.end_with?('cooked')
      cooked_recipe_path(request.referrer.match(%r{(\d+)/(cooked)$})[1])
    else
      user_ingredients_path
    end
  end

  def load_flash_messages
    @flash_messages = FlashMessages.new
  end

  def flash_messages
    @flash_messages.messages
  end
end
