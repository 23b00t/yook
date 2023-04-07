json.my_form render(partial: "shared/add_ingredient_item", formats: :html,
                    locals: { ingredient: GroceryIngredient.new })
if @grocery_item.persisted?
  json.my_ingredient render(partial: "grocery_ingredient_item", formats: :html, locals: { ingredient: @grocery_item })
  json.my_flash render(partial: "shared/flashes", formats: :html, locals: { notice: "Ingredient Added!" })
else
  json.my_flash render(partial: "shared/flashes", formats: :html, locals: { alert: "Something went wrong!" })
end
