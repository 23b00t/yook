class UserIngredientsController < ApplicationController
  before_action :set_user_ingredient, only: %i[]

  def index
    @users_ingredients = UserIngredient.all
  end

  def update
    @user_ingredient = set_user_ingredient
    @user_ingredient.update(user_ingredient_params)
  end

  def create
    @new_users_ingridient = UserIngrediant.new(user_ingredient_params)
    #need to work with this one
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
    params.require(:user_ingredient).permit(:measurement, :quantity)
  end

  def set_user_ingredient
    @ingrediant = UserIngredient.find(params[:id])
  end
end
