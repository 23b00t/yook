class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_ingrediants, dependent: :destroy
end
