class CreateGroceryIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :grocery_ingredients do |t|
      t.string :measurement
      t.float :quantity
      t.references :user, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true

      t.timestamps
    end
  end
end
