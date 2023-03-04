class FixColumnNameUserIngredients < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_ingredients, :measurment, :measurement
  end
end
