require "json"

require "nokogiri"
require "httparty"

class RecipesScraper
  attr_accessor :title, :ingredients, :description, :error, :cooking_time, :serving_size, :image_url

  def initialize(url)
    @doc = Nokogiri::HTML(HTTParty.get(url).body)
    scrape
  end

  def scrape_ingredients
    ingredients = []
    @doc.css('ul li').each do |element|
      parts = element.css("p").text
      parts = parts.split
      case parts[0]
      when "½"
        parts[0] = 0.5
      when "¼"
        parts[0] = 0.25
      end
      p parts
      if parts.count >= 3
        quantity = parts[0].to_f
        measurement = parts[1]
        name = parts[2..].join(" ")
      elsif parts.count == 2
        quantity = parts[0].to_f
        measurement = "..."
        name = parts[1..].join(" ")
      else
        quantity = 1
        measurement = "..."
        name = parts[0..].join(" ")
      end
      ingredients << { quantity: quantity, measurement: measurement, name: name } unless parts.empty?
    end
    return ingredients
  end

  def scrape_name
    name = @doc.at_css("h1").text.delete("\n").strip
    return name
  end

  def scrape_description
    description = []
    @count = 0
    @doc.css("ol li").each do |element|
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
    @list = []
    @doc.css("img").find do |img|
      unless img.attributes["id"].nil?
        @url = img.attributes["src"]
        @url = img.attributes["data-src"] if @url.nil?
        @list << @url
      end
    end
    if @list.empty?
      @url = @doc.at_css("img").attributes["src"]
      @url = @doc.at_css("img").attributes["data-src"] if @url.nil?
    else
      @url = @list.first
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

test2 = RecipesScraper.new("https://www.simplyrecipes.com/recipes/lasagna/")
puts test2.image_url
