class RenameTypeColumnInIngredientsTable < ActiveRecord::Migration[7.0]
  def change
    rename_column :ingredients, :type, :group
  end
end
