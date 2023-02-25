class UserIngredientsController < ApplicationController
  before_action :set_user_ingredient, only: %i[]

  def index
    @user_ingredients = UserIngredient.all.select{ |ingredient| ingredient.quantity > 0 }
  end

  def update
    @user_ingredient = set_user_ingredient
    @user_ingredient.update(user_ingredient_params)
  end

  def create
    @new_users_ingridient = UserIngredient.new(user_ingredient_params)
    @new_users_ingridient.ingredient_id = Ingredient.find_by(name: params[:query]).id
    @new_users_ingridient.save
    #need to work on this one
  end

  def delete
    @user_ingridient = set_user_ingredient
    if @user_ingredient.creator_id == current_user.id
      @user_ingredient.destroy
    end
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(:name, :type)
  end

  def user_ingredient_params
    params.require(:user_ingredient).permit(:measurment, :quantity)
  end

  def set_user_ingredient
    @ingrediant = UserIngredient.find(params[:id])
  end
end
