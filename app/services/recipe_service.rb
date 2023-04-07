class RecipeService
  attr_accessor :current_user

  def initialize(recipe)
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
end
