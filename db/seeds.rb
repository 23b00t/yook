# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'
require 'csv'

metric_measurement = ["kilogram", "gram", "milligram", "liter", "milliliter"]

p 'clear db'
User.destroy_all
Ingredient.destroy_all

p 'create user'
user = User.create!(email: 'test@test.com', password: 'password')

p 'create ingredients'
CSV.foreach('db/Foodlist.csv', headers: true, header_converters: :symbol) do |row|
  Ingredient.create(name: row[:name], group: row[:food_group])
end

p 'create recipes and its ingredients'
10.times do
  recipe = Recipe.create!(title: Faker::Food.dish, cooking_time: rand(120), description: Faker::Food.description, rating: rand(5), difficulty: 'hard', serving_size: 4, user_id: user.id)
  5.times do
    ingredient = Ingredient.all.sample
    RecipeIngredient.create!(recipe_id: recipe.id, ingredient_id: ingredient.id, measurement: metric_measurement.sample, quantity: rand(5))
  end
end

p 'create inventar'
20.times do
  ingredient = Ingredient.all.sample
  UserIngredient.create(measurement: metric_measurement.sample, quantity: rand(10), user_id: user.id, ingredient_id: ingredient.id)
end
