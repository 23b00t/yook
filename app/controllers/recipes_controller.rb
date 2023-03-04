class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    if params[:query].present?
      @recipes = Recipe.search_by_title_and_description(params[:query])
    else
      @recipes = Recipe.all
    end
    filter unless params[:query].nil?
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user
    if @recipe.save
      session[:recipe_id] = @recipe.id
      redirect_to ingredients_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @recipe.update(recipe_params)
      session[:recipe_id] = @recipe.id
      redirect_to ingredients_path
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
      :title, :cooking_time, :description, :rating, :difficulty, :serving_size, :cooked, :notes, :photo, :tags
    )
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def filter
    @recipes = RecipeFilter.new(@recipes)
                           .filter_by_cooked(params[:cooked])
                           .filter_by_cooking_time(params[:cooking_time])
                           .filter_by_difficulty(params[:difficulty])
                           .filter_by_rating(params[:rating])
                           .filter_by_tags(params[:tags])
                           .sort_by_user_ingredients(params[:active])
    @matches = @recipes.instance_variable_get(:@matches)
    @recipes = @recipes.results
  end
end
