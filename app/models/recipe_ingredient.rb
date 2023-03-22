class RecipeIngredient < ApplicationRecord
  belongs_to :ingredient
  belongs_to :recipe

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, :measurement, presence: true
end
