class RecipeIngredient < ApplicationRecord
  belongs_to :ingredient
  belongs_to :recipe

  validates :quantity, numericality: true
  validates :quantity, :measurment, presence: true
end
