require 'csv'

p 'clear db'
User.destroy_all
Ingredient.destroy_all

p 'create user'
user = User.create!(email: 'test@test.com', password: 'password')

p 'create ingredients'
CSV.foreach('db/Foodlist.csv', headers: true, header_converters: :symbol) do |row|
  Ingredient.create(name: row[:name], group: row[:food_group])
end

# CSV.foreach('db/ingredients.csv') do |row|
#   Ingredient.create(name: row[0])
#   p row[0]
# end

p 'Scrape recipes'
RecipeService.new(user).create_with_scrape(link: "https://www.allrecipes.com/recipe/14276/strawberry-spinach-salad-i/")
RecipeService.new(user).create_with_scrape(link: "https://www.allrecipes.com/recipe/8887/chicken-marsala/")
RecipeService.new(user).create_with_scrape(link: "https://www.allrecipes.com/recipe/15925/creamy-au-gratin-potatoes/")
RecipeService.new(user).create_with_scrape(link: "https://www.allrecipes.com/recipe/282286/easy-veggie-pasta-primavera/")
RecipeService.new(user).create_with_scrape(link: "https://www.allrecipes.com/recipe/16947/amazingly-easy-irish-soda-bread/")

p 'All done'
