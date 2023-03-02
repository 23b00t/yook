class RecipeFilter
  def initialize(scope = Recipe.all)
    @scope = scope
  end

  def filter_by_cooked(cooked)
    @scope = @scope.select { |recipe| recipe.cooked.to_s == cooked || recipe.cooked.nil? }
    self
  end

  def filter_by_cooking_time(cooking_time)
    unless cooking_time.empty?
      time = cooking_time.scan(/\d+/).map(&:to_i)
      @scope = @scope.reject { |recipe| recipe.cooking_time < time[0] || recipe.cooking_time > time[1] }
    end
    self
  end

  def filter_by_difficulty(difficulty)
    @scope = @scope.select { |recipe| recipe.difficulty == difficulty } unless difficulty.empty?
    self
  end

  def filter_by_rating(rating)
    @scope = @scope.select { |recipe| recipe.rating >= rating.to_i } unless rating.empty?
    self
  end

  def filter_by_tags(tags)
    unless tags.empty?
      tag_matches = Recipe.search_by_tag(tags)
      @scope = @scope.select { |recipe| tag_matches.include? recipe }
    end
    self
  end

  # def filter_by_user_ingredients(active)
  #   if active
  #     match = @scope.map do |recipe|
  #       recipe.recipe_ingredients.map do |ingredient|
  #         UserIngredient.all.include? ingredient.ingredient_id
  #       end
  #     end
  #     raise
  #   end
  # end

  def results
    @scope
  end
end
