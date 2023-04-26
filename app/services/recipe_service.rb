class RecipeService
  include TimeHelper
  include UnitHelpers
  attr_accessor :current_user

  def initialize(current_user, recipe = nil)
    @recipe = recipe
    @current_user = current_user
  end

  def cooked
    ingredients = @recipe.recipe_ingredients
    ingredients.each do |ingredient|
      @user_ingredient = @current_user.user_ingredients.find_by(ingredient_id: ingredient.ingredient_id)
      next if !@user_ingredient.present? || @user_ingredient.quantity <= 0

      substract_ingredients(@user_ingredient, ingredient)
      next unless @quantity.present?

      @user_ingredient.update(quantity: @quantity.positive? ? @quantity : 0, measurement: @user_ingredient.measurement)
    end

    @recipe.update(cooked: true)
  end

  def create_grocery_list
    @recipe.recipe_ingredients.each do |ingredient|
      user_ingredient = UserIngredient.find_by(ingredient_id: ingredient.ingredient_id)
      next if user_ingredient.present? && user_ingredient.quantity >= ingredient.quantity

      grocery_ingredient = GroceryIngredient.find_by(ingredient: ingredient.ingredient)

      update_or_create_gorcery_ingredient(grocery_ingredient, ingredient)
    end
  end

  def create_with_scrape(params)
    scrape = RecipesScraper.new(params[:link])
    @recipe = Recipe.new(title: scrape.title, cooking_time: transform_time(scrape.cooking_time),
                         serving_size: scrape.serving_size, description: scrape.description, user: current_user)
    @recipe.scraped_img_url = scrape.image_url
    return { success: false, message: FlashMessages.scrape_error } if scrape.error.present?

    @recipe.save
    scrape_ingredients(scrape, @recipe)
    { success: true, recipe: @recipe }
  end

  private

  def scrape_ingredients(scrape, recipe)
    scrape.ingredients.each do |ingredient|
      new_ing = RecipeIngredient.new({ measurement: adjust_measurement(ingredient[:measurement]),
                                       quantity: ingredient[:quantity], comment: ingredient[:comment] })
      ing = Ingredient.where('lower(name) = ?', ingredient[:name].downcase).first ||
            Ingredient.create({ name: ingredient[:name], creator: @current_user })
      new_ing.recipe = recipe
      new_ing.ingredient = ing
      new_ing.save
    end
  end

  def update_or_create_gorcery_ingredient(grocery_ingredient, ingredient)
    if grocery_ingredient.present?
      sum_ingredients(grocery_ingredient, ingredient)
      grocery_ingredient.update(quantity: @quantity) if @quantity.present?
    else
      GroceryIngredient.create(
        ingredient: ingredient.ingredient, measurement: ingredient.measurement,
        quantity: ingredient.quantity, user: @current_user
      )
    end
  end
end
