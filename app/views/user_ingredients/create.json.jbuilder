if @new_users_ingredient.persisted?
  json.my_form render(partial: "shared/add_ingredient_item", formats: :html, locals: { ingredient: UserIngredient.new })
  json.my_ingredient render(partial: "shared/ingredient_item", formats: :html, locals: { ingredient: @new_users_ingredient })
end
