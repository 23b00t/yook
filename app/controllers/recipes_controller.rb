require "#{Rails.root}/lib/flash_messages"

class RecipesController < ApplicationController
  include TimeHelper
  include UnitHelpers

  before_action :set_recipe, except: %i[index new new_scrape new_manual create]
  before_action :new_recipe, only: %i[new new_scrape new_manual]

  def index
    @recipes = params[:query].present? ? Recipe.search_by_title_and_description(params[:query]) : Recipe.all

    filter unless params[:query].nil?
    @recipes = @recipes.select { |recipe| recipe.user == current_user }

    respond_to do |format|
      format.html
      format.text { render partial: "recipes/list", formats: [:html] }
    end
  end

  def new; end

  def new_scrape; end

  def new_manual; end

  def create
    params[:link].present? ? create_from_link : create_from_form
  end

  def show
    @steps = @recipe.description.split(/\(Step \d+\)/).reject(&:empty?)
  end

  def edit; end

  def update
    prepare_recipe_params
    if @recipe.update(recipe_params)
      session[:recipe_id] = @recipe.id
      redirect_to recipe_recipe_ingredients_path(@recipe)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, status: :see_other
  end

  def edit_description; end

  def update_description
    @recipe.update(recipe_params) ? (redirect_to recipe_path(@recipe)) : (render :edit_description)
  end

  def cooked
    RecipeService.new(@recipe, current_user).cooked

    if @alert_msg.present?
      redirect_to user_ingredients_path, alert: @alert_msg
    else
      redirect_to recipe_path(@recipe), notice: FlashMessages.cooked_msg
    end
  end

  def create_grocery_list
    RecipeService.new(@recipe, current_user).create_grocery_list

    redirect_to recipe_path(@recipe), notice: FlashMessages.groceries_created
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

  def new_recipe
    @recipe = Recipe.new
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

  def create_from_link
    result = RecipeService.new(current_user).recipe_service.create_with_scrape(params)
    redirect_path = result[:success] ? edit_recipe_path(result[:recipe]) : new_recipe_path
    redirect_to redirect_path, alert: result[:message]
  end

  def create_from_form
    prepare_recipe_params
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user
    adjust_ingredients_measurement
    if @recipe.save
      session[:recipe_id] = @recipe.id
      redirect_to recipe_recipe_ingredients_path(@recipe)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def prepare_recipe_params
    params[:recipe][:tags] = params[:recipe][:tags].join(' ')
    params[:recipe][:cooking_time] = transform_time(params[:recipe][:cooking_time])
  end

  def adjust_ingredients_measurement
    @recipe.ingredients.each { |ingredient| ingredient.measurement = adjust_measurement(ingredient) }
  end
end
