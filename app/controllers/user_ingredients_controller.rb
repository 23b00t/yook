class UserIngredientsController < ApplicationController
  before_action :set_user_ingredient, only: %i[update destroy]

  def index
    UserIngredient.all.each { |ingredient| convert(ingredient) }
    @user_ingredients = UserIngredient.all.select { |i| i.quantity.positive? && i.favorited && i.user_id = current_user.id }
    @user_ingredients += UserIngredient.all.select { |i| i.quantity.positive? && !i.favorited && i.user_id = current_user.id }
    @new_ingredient = UserIngredient.new
  end

  def update
    @ingredient.update(ingredient_params)
    convert(@ingredient)
    redirect_to ingredients_path
  end

  def create
    @ing = Ingredient.find_by(name: params[:name].downcase.capitalize)

    if @ing
      @new_users_ingredient = UserIngredient.new(user_ingredient_params)
      @new_users_ingredient.ingredient_id = @ing.id
      @new_users_ingredient.user_id = current_user.id
      @new_users_ingredient.save
    else
      redirect_to user_ingredients_path
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
