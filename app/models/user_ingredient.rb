class UserIngredient < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient
  # next line breaks creation of new user_ingredients, wasn't able to add Apple although it wasn't in the inventory
  # validates :ingredient_id, uniqueness: { scope: :user_id }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :ingredient_id, uniqueness: { scope: :user_id }
end
