class Recipe < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  validates :title, presence: true
  has_one_attached :photo

  pg_search_scope :search_by_title_and_description,
                  against: %i[title description],
                  using: {
                    tsearch: { prefix: true }
                  }

  pg_search_scope :search_by_tag,
                  against: :tags,
                  using: {
                    tsearch: { prefix: true }
                  }
end
