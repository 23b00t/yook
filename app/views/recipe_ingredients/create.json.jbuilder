if @recipe_ingredient.persisted?
  json.my_form render(partial: "shared/add_ingredient_item", formats: :html, locals: { ingredient: RecipeIngredient.new })
  json.my_ingredient render(partial: "shared/ingredient_item", formats: :html, locals: { ingredient: @recipe_ingredient })
  json.my_flash render(partial: "shared/flashes", formats: :html, locals: {notice: "Ingredient Added!" })
else
  json.my_form render(partial: "shared/add_ingredient_item", formats: :html, locals: { ingredient: RecipeIngredient.new })
  json.my_flash render(partial: "shared/add_ingredient_item", formats: :html, locals: {alert: "Something went wrong!" })
end
