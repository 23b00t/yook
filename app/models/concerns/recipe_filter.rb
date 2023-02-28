class RecipeFilter
  def initialize(scope = Recipe.all)
    @scope = scope
  end

  def filter_by_cooked(cooked)
    @scope = @scope.select { |recipe| recipe.cooked.to_s == cooked || recipe.cooked.nil? }
    self
  end

  def filter_by_cooking_time(cooking_time)
    unless cooking_time.nil? || cooking_time.empty?
      time = cooking_time.scan(/\d+/).map(&:to_i)
      @scope = @scope.reject { |recipe| recipe.cooking_time < time[0] || recipe.cooking_time > time[1] }
    end
    self
  end

  def filter_by_difficulty(difficulty)
    @scope = @scope.select { |recipe| recipe.difficulty == difficulty } unless difficulty.nil? || difficulty.empty?
    self
  end

  def filter_by_rating(rating)
    @scope = @scope.select { |recipe| recipe.rating >= rating.to_i } unless rating.nil? || rating.empty?
    self
  end

  def filter_by_tags(tags = nil)
    unless tags.nil? || tags.empty?
      tag_matches = Recipe.search_by_tag(tags)
      @scope = @scope.select { |recipe| tag_matches.include? recipe }
    end
    self
  end

  def results
    @scope
  end
end
