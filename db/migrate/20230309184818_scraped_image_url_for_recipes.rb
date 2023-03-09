class ScrapedImageUrlForRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :scraped_img_url, :string
  end
end
