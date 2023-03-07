require "json"
require "open-uri"
require "nokogiri"

class RecipesScraper
  attr_accessor :title, :ingredients, :description, :error, :cooking_time, :serving_size

  def initialize(url)
    @title = "Unnamed recipe"
    @ingredients = "Sorry, we cant find any ingredients to this recipe"
    @error = ""
    @description = "There is no desxription to this meal"
    begin
      @doc = Nokogiri::HTML(URI.open(url))
      scrape
    rescue
      @error = true
    end
  end

  def scrape_ingredients
    ingredients = []
    @doc.css('.mntl-structured-ingredients p').each do |element|
      parts = element.css("span")
      hash = { measurement: parts[1].text, quantity: parts[0].text, name: parts[2].text }
      ingredients << hash
    end
    return ingredients
  end

  def scrape_name
    name = @doc.css(".article-heading").text.delete("\n").strip
    return name
  end

  def scrape_description
    description = []
    @doc.css(".recipe__steps p").each do |element|
      description << element.text.delete("\n").strip
    end
    return description
  end

  def scrape_time_serving
    serving_size_time = []
    @doc.css(".mntl-recipe-details__value").each do |element|
      serving_size_time << element.text.delete("\n").strip
    end
    return serving_size_time
  end

  def scrape
    @ingredients = scrape_ingredients
    @title = scrape_name
    @description = scrape_description
    @cooking_time = scrape_time_serving[2]
    @serving_size = scrape_time_serving[3]
  end
end
