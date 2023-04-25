module FlashMessages
  module_function

  def scrape_error
    "Problems importing your recipe! Have you put in the right link?"
  end

  def measurement_error(ingredient1, ingredient2)
    "The measurement of the #{ingredient1.ingredient.name.capitalize} in your fridge is: #{ingredient2.measurement}.\n
     You have used #{ingredient1.quantity} #{ingredient1.measurement}. Please adjust it manually"
  end

  def cooked_msg
    'Marked as cooked and updated your fridge'
  end

  def groceries_created
    'Added missing ingredients to grocery list'
  end

  def doubble_entry
    "You already have this ingredient in Fridge! Please change the quantity manualy!"
  end

  def success
    "Updated successfully"
  end

  def negative_quantity_error
    "Quantity can't be lower than 0"
  end

  def purchased
    "Ingredient(s) was purchased! Check your Inventory!"
  end
end
