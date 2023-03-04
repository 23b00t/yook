class FavoritedDefaultValueFalse < ActiveRecord::Migration[7.0]
  def change
    change_column :user_ingredients, :favorited, :boolean, default: false
  end
end
