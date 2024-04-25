# frozen_string_literal: true

# String helpers
class ::String
  def bool_to_symbol
    case self
    when /NOT/
      :not
    when /AND/
      :and
    else
      :or
    end
  end

  def date?
    match(/^\d{4}-\d{2}-\d{2}/) ? true : false
  end

  def time?
    match(/ \d{1,2}(:\d\d)? *([ap]m)?/i)
  end

  def to_date
    Chronic.parse(self)
  end

  def strip_time
    sub(/ \d{1,2}(:\d\d)? *([ap]m)?/i, '')
  end

  def to_day(time = :end)
    t = time == :end ? '23:59' : '00:00'
    Chronic.parse("#{self.strip_time} #{t}")
  end
end
