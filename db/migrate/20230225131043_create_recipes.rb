class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :title
      t.integer :cooking_time
      t.text :description
      t.integer :rating
      t.string :difficulty
      t.integer :serving_size
      t.boolean :cooked
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
