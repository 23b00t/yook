require "json"

require "nokogiri"
require "httparty"

class RecipesScraper
  attr_accessor :title, :ingredients, :description, :error, :cooking_time, :serving_size, :image_url

  def initialize(url)
    begin
      @doc = Nokogiri::HTML(HTTParty.get(url).body)
      scrape
    rescue
      @error = true
    end
  end

  def scrape_ingredients
    ingredients = []
    @doc.css('ul li').each do |element|
      parts = element.css("p").text
      parts = parts.split

      ingredients << {quantity: parts[0].to_i, measurement: parts[1], name: parts[2..].join(" ")} unless parts.empty?
    end
    return ingredients
  end

  def scrape_name
    name = @doc.at_css("h1").text.delete("\n").strip
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

  def scrape_img_url
    @doc.css("img").each do |img|
      unless img.attributes["id"].nil?
        @url = img.attributes["src"]
        @url = img.attributes["data-src"] if @url.nil?
      end
    end
    if @url.nil?
      @url = @doc.at_css("img").attributes["src"]
      @url = @doc.at_css("img").attributes["data-src"] if @url.nil?
    end
    return @url
  end

  def scrape
    @ingredients = scrape_ingredients
    @title = scrape_name
    @description = scrape_description
    @cooking_time = scrape_time_serving[2]
    @serving_size = scrape_time_serving[3]
    @image_url = scrape_img_url
  end
end

test2 = RecipesScraper.new("https://www.allrecipes.com/recipe/285077/easy-one-pot-ground-turkey-pasta/")
p test2.ingredients
