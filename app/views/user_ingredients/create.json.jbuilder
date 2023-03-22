if @new_users_ingredient.persisted?
  json.my_ingredient render(partial: "shared/ingredient_item", formats: :html, locals: { ingredient: @new_users_ingredient })
  json.my_flash render(partial: "shared/flashes", formats: :html, locals: { notice: "Ingredient Added!" })
  json.my_form render(partial: "shared/add_ingredient_item", formats: :html, locals: { ingredient: UserIngredient.new })
else
  json.my_flash render(partial: "shared/flashes", formats: :html, locals: { alert: "You already have this ingredient in Fridge! please change the quantity manualy!" })
  json.my_form render(partial: "shared/add_ingredient_item", formats: :html, locals: { ingredient: UserIngredient.new })
end
