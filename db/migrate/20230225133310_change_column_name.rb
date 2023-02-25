class ChangeColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :recipe_ingredients, :measurement, :measurment
  end
end
