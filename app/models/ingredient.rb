class Ingredient < ApplicationRecord
  include PgSearch::Model

  belongs_to :creator, class_name: "User", optional: true
  validates :name, presence: true, uniqueness: true

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true }
                  }
end
