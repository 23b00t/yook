require 'ruby-units'

module UnitHelpers
  private

  def adjust_measurement(measurement)
    Unit.new(measurement).units
  rescue ArgumentError
    'U'
  end

  def substract_ingredients(ingredient1, ingredient2)
    unit1 = Unit.new("#{ingredient1.quantity} #{ingredient1.measurement}")
    unit2 = Unit.new("#{ingredient2.quantity} #{ingredient2.measurement}")
    (unit1 - unit2).to(ingredient1.measurement).round(4)
  end

  def sum_ingredients(ingredient1, ingredient2)
    unit1 = Unit.new("#{ingredient1.quantity} #{ingredient1.measurement}")
    unit2 = Unit.new("#{ingredient2.quantity} #{ingredient2.measurement}")
    (unit1 + unit2).to(ingredient1.measurement).round(4)
  end
end
