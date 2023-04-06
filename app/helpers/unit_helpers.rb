module UnitHelpers
  private

  def adjust_measurement(measurement)
    Unit.new(measurement).units
  rescue ArgumentError
    'U'
  end

  def substract_ingredients(ingredient_1, ingredient_2)
    unit_1 = Unit.new("#{ingredient_1.quantity} #{ingredient_1.measurement}")
    unit_2 = Unit.new("#{ingredient_2.quantity} #{ingredient_2.measurement}")
    (unit_1 - unit_2).to(ingredient_1.measurement).round(4)
  end

  def sum_ingredients(ingredient_1, ingredient_2)
    unit_1 = Unit.new("#{ingredient_1.quantity} #{ingredient_1.measurement}")
    unit_2 = Unit.new("#{ingredient_2.quantity} #{ingredient_2.measurement}")
    (unit_1 + unit_2).to(ingredient_1.measurement).round(4)
  end
end
