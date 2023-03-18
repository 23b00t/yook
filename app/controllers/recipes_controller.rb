require "open-uri"
require 'ruby-units'

class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy cooked create_grocery_list]

  def index
    if params[:query].present?
      @recipes = Recipe.search_by_title_and_description(params[:query])
    else
      @recipes = Recipe.all
    end

    filter unless params[:query].nil?
    @recipes = @recipes.select { |recipe| recipe.user == current_user }

    respond_to do |format|
      format.html
      format.text { render partial: "recipes/list", formats: [:html] }
    end
  end

  def new
    @recipe = Recipe.new
  end

  def new_scrape
    @recipe = Recipe.new
  end

  def new_manual
    @recipe = Recipe.new
  end

  def create
    if params[:link].present?
      scrape = RecipesScraper.new(params[:link])
      @recipe = Recipe.new(title: scrape.title, cooking_time: scrape.cooking_time, serving_size: scrape.serving_size, description: scrape.description)
      @recipe.scraped_img_url = scrape.image_url
      @recipe.user = current_user
      if scrape.error.present?
        redirect_to new_recipe_path, alert: "Problems importing your recipe! Have you put in the right link?"
      else
        @recipe.save
        scrape.ingredients.each do |ingredient|
          new_ing = RecipeIngredient.new({ measurement: ingredient[:measurement], quantity: ingredient[:quantity] })
          Ingredient.new({ name: ingredient[:name] }).save
          new_ing.recipe = @recipe
          new_ing.ingredient = Ingredient.find_by(name: ingredient[:name])
          new_ing.save
        end
        redirect_to edit_recipe_path(@recipe)
      end
    else
      params[:recipe][:tags] = params[:recipe][:tags].join(' ')
      @recipe = Recipe.new(recipe_params)
      @recipe.user = current_user
      if @recipe.save
        session[:recipe_id] = @recipe.id
        redirect_to ingredients_path
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def show
    @edit = false
  end

  def edit; end

  def update
    params[:recipe][:tags] = params[:recipe][:tags].join(' ')
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

  def edit_description
    @recipe = Recipe.find(params[:id])
  end

  def update_description
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to recipe_path(@recipe)
    else
      render :edit_description
    end
  end

  def cooked
    ingredients = @recipe.recipe_ingredients
    ingredients.each do |ingredient|
      @user_ingredient = UserIngredient.where(ingredient_id: ingredient.ingredient_id).first
      next if !@user_ingredient.present? || @user_ingredient.quantity <= 0

      unit1 = Unit.new("#{@user_ingredient.quantity} #{@user_ingredient.measurement}")
      unit2 = Unit.new("#{ingredient.quantity} #{ingredient.measurement}")
      begin
        unit3 = (unit1 - unit2).to(@user_ingredient.measurement).round(4)
      rescue ArgumentError
        @edit = true
        flash.now[:alert] = "The measurement of the ingredient in your fridge is: #{@user_ingredient.measurement}.\n
                             You have used #{ingredient.quantity} #{ingredient.measurement}. Please adjust it manually
                             to #{ingredient.measurement}"
        return render :show
      end
      quantity = unit3.scalar
      if quantity.positive?
        @user_ingredient.update(quantity:, measurement: @user_ingredient.measurement)
      else
        @user_ingredient.update(quantity: 0, measurement: @user_ingredient.measurement)
      end
    end
    @recipe.cooked = true
    redirect_to recipe_path(@recipe), notice: 'Marked as cooked and updated your fridge'
  end

  def create_grocery_list
    @recipe.recipe_ingredients.each do |ingredient|
      next if UserIngredient.all.where(ingredient_id: ingredient.ingredient).present?

      grocery_ingredient = GroceryIngredient.where(ingredient: ingredient.ingredient)
      if grocery_ingredient.present?
        new_quantity = grocery_ingredient.first.quantity + ingredient.quantity
        GroceryIngredient.update(quantity: new_quantity)
      else
        GroceryIngredient.create(
          ingredient: ingredient.ingredient, measurement: ingredient.measurement,
          quantity: ingredient.quantity, user: current_user
        )
      end
    end
    redirect_to recipe_path(@recipe), notice: 'Added missing ingredients to grocery list'
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
