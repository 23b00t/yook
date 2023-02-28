class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    @recipes = Recipe.all
    @recipes = Recipe.search_by_title_and_description(params[:query]) if params[:query].present?
    filters
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
      :title, :cooking_time, :description, :rating, :difficulty, :serving_size, :cooked, :notes, :photo, :tags
    )
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def filters
    @recipes = @recipes.select { |recipe| recipe.cooked.to_s == params[:cooked] || recipe.cooked.nil? } if params[:cooked].present?

    if params[:cooking_time].present?
      time = params[:cooking_time].scan(/\d+/).map(&:to_i)
      @recipes = @recipes.reject { |recipe| recipe.cooking_time < time[0] || recipe.cooking_time > time[1] }
    end

    @recipes = @recipes.select { |recipe| recipe.difficulty == params[:difficulty] } if params[:difficulty].present?

    @recipes = @recipes.select { |recipe| recipe.rating >= params[:rating].to_i } if params[:rating].present?

    if params[:tags].present?
      tag_matches = Recipe.search_by_tag(params[:tags])
      @recipes = @recipes.select { |recipe| tag_matches.include? recipe }
    end

    @recipes
  end
end
