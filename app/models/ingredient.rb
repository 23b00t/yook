class Ingredient < ApplicationRecord
  belongs_to :creator, class_name: "User", optional: true
  validates :name, presence: true, uniqueness: true
end
