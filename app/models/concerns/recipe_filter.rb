class RecipeFilter
  def initialize(scope = Recipe.all)
    @scope = scope
  end

  def filter_by_cooked(cooked)
    cooked = cooked == 'yes'
    @scope = @scope.select { |recipe| recipe.cooked == cooked || recipe.cooked.nil? }
    self
  end

  def filter_by_cooking_time(cooking_time)
    unless cooking_time.nil? || cooking_time.empty?
      time = cooking_time.scan(/\d+/)
      @scope = @scope.reject do |recipe|
        recipe.cooking_time.nil? || (recipe.cooking_time.to_i < time[0] || recipe.cooking_time.to_i > time[1])
      end
    end
    self
  end

  def filter_by_difficulty(difficulty)
    unless difficulty.nil? || difficulty.empty?
      @scope = @scope.select do |recipe|
        !recipe.difficulty.nil? && recipe.difficulty == difficulty
      end
    end
    self
  end

  def filter_by_rating(rating)
    unless rating.nil? || rating.empty?
      @scope = @scope.select { |recipe| !recipe.rating.nil? && recipe.rating >= rating.to_i }
    end
    self
  end

  def filter_by_tags(tags)
    unless tags.nil? || tags.empty?
      tag_matches = Recipe.search_by_tag(tags)
      @scope = @scope.select { |recipe| tag_matches.include? recipe }
    end
    self
  end

  def sort_by_user_ingredients(active)
    if active
      @matches = {}
      @scope.each do |recipe|
        @matches[recipe] = recipe.recipe_ingredients.map do |recipe_ingredient|
          UserIngredient.where(ingredient: recipe_ingredient.ingredient).present? &&
            UserIngredient.where(ingredient: recipe_ingredient.ingredient).first.quantity.positive?
        end
      end
      sort
    end
    self
  end

  def results
    @scope
  end

  private

  def sort
    @matches.each { |k, v| @matches[k] = v.count(true).fdiv(v.length) }
    @scope = @matches.keys.sort_by do |k|
      match_percentage = @matches[k].is_a?(Float) ? @matches[k] : @matches[k][0]
      match_percentage = 0 if match_percentage.nan?
      [-match_percentage, k.title]
    end
  end
end
