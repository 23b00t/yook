class Ingredient < ApplicationRecord
  include PgSearch::Model

  belongs_to :creator, class_name: "User", optional: true
  has_many :user_ingredients, dependent: :destroy
  has_many :grocery_ingredients, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true }
                  }
end
