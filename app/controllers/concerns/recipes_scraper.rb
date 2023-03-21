require "json"
require "nokogiri"
require "httparty"
require 'ruby-units'

class RecipesScraper
  attr_accessor :title, :ingredients, :description, :error, :cooking_time, :serving_size, :image_url

  def initialize(url)
    @doc = Nokogiri::HTML(HTTParty.get(url).body)
    scrape
  end

  def scrape_ingredients
    ingredients = []
    @doc.css('ul li').each do |element|
      parts = element.css("p").text.split.reject(&:empty?)
      next if parts.empty?

      name = parts.select { |word| Ingredient.where('name ILIKE ?', word).present? }.join(' ')
      case parts.first
      when "½" then parts[0] = "0.5"
      when "¼" then parts[0] = "0.25"
      end
      quantity = parts.first if numeric?(parts.first)
      measurement = parts.select { |unit| valid_unit?(unit) }.first
      comment = parts.reject { |word| word.eql?(quantity) || word.eql?(measurement) || name.include?(word) }.join(' ')
      if name.empty?
        name = comment
        comment = ''
      end
      ingredients << { quantity:, measurement:, name:, comment: }
    end
    # raise
    ingredients
  end

  def scrape_name
    name = @doc.at_css("h1").text.delete("\n").strip
    return name
  end

  def scrape_description
    description = []
    @count = 0
    @doc.css(".recipe__steps li").each do |element|
      @count += 1
      description << "(Step #{@count})\n #{element.text.delete("\n").strip}\n"
    end
    return description.join
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

  private

  def valid_unit?(unit_string)
    unit = Unit.new(unit_string).units
    return false if unit.empty?

    true
  rescue ArgumentError
    false
  end

  def numeric?(string)
    true if Float(string)
  rescue ArgumentError
    false
  end
end

# test2 = RecipesScraper.new("https://www.allrecipes.com/recipe/16947/amazingly-easy-irish-soda-bread/")
# puts test2.ingredients
