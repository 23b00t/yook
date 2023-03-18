class ChangeCookedDefaultValue < ActiveRecord::Migration[7.0]
  def change
    change_column_default :recipes, :cooked, from: nil, to: false
  end
end
