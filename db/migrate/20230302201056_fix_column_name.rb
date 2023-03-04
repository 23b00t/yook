class FixColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :recipe_ingredients, :measurment, :measurement
  end
end
