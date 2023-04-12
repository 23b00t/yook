require "json"
require "nokogiri"
require "httparty"
require 'ruby-units'

class RecipesScraper
  attr_accessor :title, :ingredients, :description, :error, :cooking_time, :serving_size, :image_url

  def initialize(url)
    @document = Nokogiri::HTML(HTTParty.get(url).body)
    scrape
  end

  def scrape_ingredients
    ingredients = []

    @document.css('ul li').each do |element|
      parts = element.css("p").text.split.reject(&:empty?)
      next if parts.empty?

      name = find_ingredient_name(parts)
      quantity, measurement, comment = extract_quantity_measurement_and_comment(parts, name)

      ingredients << { quantity:, measurement:, name:, comment: }
    end

    ingredients
  end

  def scrape_name
    @document.at_css("h1").text.delete("\n").strip
  end

  def scrape_description
    @document.css("ol li").map.with_index do |element, index|
      "(Step #{index})\n #{element.text.delete("\n").strip}\n"
    end.join
  end

  def scrape_time_serving
    @document.css(".mntl-recipe-details__value").map do |element|
      element.text.delete("\n").strip
    end
  end

  def scrape_img_url
    @document.css("img").find do |img|
      next if img.attributes["id"].nil?

      @url = img.attributes["src"].nil? ? img.attributes["data-src"] : img.attributes["src"]
    end
    unless @url.present?
      @url = @document.at_css("img").attributes["src"]
      @url = @document.at_css("img").attributes["data-src"] if @url.nil?
    end
    @url
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

  def find_ingredient_name(parts)
    name = parts.find { |word| Ingredient.where('name ILIKE ?', word).present? }
    name || parts.join(' ')
  end

  def extract_quantity_measurement_and_comment(parts, ingredient_name)
    handle_fractionals(parts)

    quantity = parts.first if numeric?(parts.first)
    measurement = parts.find { |unit| valid_unit?(unit) }
    comment = parts.reject do |word|
      word.eql?(quantity) || word.eql?(measurement) || ingredient_name.include?(word)
    end.join(' ')

    [quantity, measurement, comment]
  end

  def handle_fractionals(parts)
    case parts.first
    when "½" then parts[0] = "0.5"
    when "¼" then parts[0] = "0.25"
    end
  end
end
