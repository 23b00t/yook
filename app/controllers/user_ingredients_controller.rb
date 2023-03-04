class UserIngredientsController < ApplicationController
  before_action :set_user_ingredient, only: %i[]

  def index
    UserIngredient.all.each { |ingredient| convert(ingredient) }
    @user_ingredients = UserIngredient.all.select { |i| i.quantity.positive? && i.favorited && i.user_id = current_user.id }
    @user_ingredients += UserIngredient.all.select { |i| i.quantity.positive? && !i.favorited && i.user_id = current_user.id }
  end

  def update
    @user_ingredient = set_user_ingredient
    @user_ingredient.update(user_ingredient_params)
    convert(@user_ingredient)
    redirect_to user_ingredients_path
  end

  def create
    @new_users_ingredient = UserIngredient.new(user_ingredient_params)
    if Ingredient.find_by(name: params[:name]).nil?
      redirect_to user_ingredients_path
    else
      @new_users_ingredient = UserIngredient.new(user_ingredient_params)
      @new_users_ingredient.ingredient_id = Ingredient.find_by(name: params[:name]).id
      @new_users_ingredient.user_id = current_user.id
      @new_users_ingredient.save
    end
  end

  def delete
    @user_ingridient = set_user_ingredient
    if @user_ingredient.creator_id == current_user.id
      @user_ingredient.destroy
    end
  end

  private

  def user_ingredient_params
    params.require(:user_ingredient).permit(:measurment, :quantity, :favorited)
  end

  def set_user_ingredient
    @ingrediant = UserIngredient.find(params[:id])
  end

  #automaticly converts measurment 1000g = 1kg and so on
  def convert(ingredient)
    if ingredient.quantity >= 1000
      case ingredient.measurment
      when "gram"
        ingredient.quantity /= 1000
        ingredient.measurment = "kilogram"
        ingredient.save
      when "milligram"
        ingredient.quantity /= 1000
        ingredient.measurment = "gram"
        ingredient.save
      when "milliliter"
        ingredient.quantity /= 1000
        ingredient.measurment = "liter"
        ingredient.save
      end
    end
  end
end
