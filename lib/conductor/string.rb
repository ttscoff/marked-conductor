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

  def number?
    to_f > 0
  end

  def bool?
    match(/^(?:y(?:es)?|no?|t(?:rue)?|f(?:alse)?)$/) ? true : false
  end

  def to_bool!
    replace to_bool
  end

  ##
  ## Returns a bool representation of the string.
  ##
  ## @return     [Boolean] Bool representation of the object.
  ##
  def to_bool
    case self
    when /^[yt]/i
      true
    else
      false
    end
  end
end
