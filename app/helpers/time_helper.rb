module TimeHelper
  private

  def transform_time(time)
    match = time.match(/(\d+)\s*(hrs?|hours?|h?)?\s*(\d+)?\s*(mins?|minutes?)?/)
    return "0" unless match

    hours, minutes = match[2].to_s.downcase.start_with?("h") ? [match[1].to_i, match[3].to_i] : [0, match[1].to_i]
    return "0" if hours.zero? && minutes.zero?

    return ((hours * 60) + minutes).to_s
  end
end
