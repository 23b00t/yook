class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user
    if @recipe.save
      redirect_to recipe_path(@recipe)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @recipe.update(recipe_params)
      redirect_to recipe_path(@recipe)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, status: :see_other
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title, :cooking_time, :description, :rating, :difficulty, :serving_size, :cooked, :notes, :photo
    )
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
