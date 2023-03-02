class UserIngredient < ApplicationRecord
  belongs_to :user
  belongs_to :ingredient
  validates :ingredient_id, uniqueness: { scope: :user_id }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
