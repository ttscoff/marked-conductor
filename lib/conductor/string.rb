# frozen_string_literal: true

# String helpers
class ::String
  ##
  ## Convert a string boolean to symbol
  ##
  ## @return     [Symbol] symbolized version
  ##
  def bool_to_symbol
    case self
    when /(NOT|!!)/
      :not
    when /(AND|&&)/
      :and
    else
      :or
    end
  end

  ##
  ## Test a string to see if it's a UTC date
  ##
  ## @return     [Boolean] test result
  ##
  def date?
    dup.force_encoding("utf-8").match?(/^\d{4}-\d{2}-\d{2}$/)
  end

  ##
  ## Test a string to see if it includes a time
  ##
  ## @return     [Boolean] test result
  ##
  def time?
    dup.force_encoding("utf-8").match(/ \d{1,2}(:\d\d)? *([ap]m)?/i)
  end

  ##
  ## Convert a natural language string to a Date
  ##             object
  ##
  ## @return     [Date] Resulting Date object
  ##
  def to_date
    Chronic.parse(dup.force_encoding("utf-8"))
  end

  ##
  ## Remove time from string
  ##
  ## @return     [String] string with time removed
  ##
  def strip_time
    dup.force_encoding("utf-8").sub(/ \d{1,2}(:\d\d)? *([ap]m)?/i, "")
  end

  def to_day(time = :end)
    t = time == :end ? "23:59" : "00:00"
    Chronic.parse("#{strip_time} #{t}")
  end

  ##
  ## Test if a string is a number
  ##
  ## @return     [Boolean] test result
  ##
  def number?
    to_f.positive?
  end

  ##
  ## Test if a string is a boolean
  ##
  ## @return     [Boolean] test result
  ##
  def bool?
    dup.force_encoding("utf-8").match?(/^(?:y(?:es)?|no?|t(?:rue)?|f(?:alse)?)$/)
  end

  ##
  ## Test if string starts with YAML
  ##
  ## @return     [Boolean] test result
  ##
  def yaml?
    dup.force_encoding('utf-8').match?(/^---/m)
  end

  ##
  ## Test if a string starts with MMD metadata
  ##
  ## @return     [Boolean] test result
  ##
  def meta?
    dup.force_encoding('utf-8').match?(/^\w+: +\S+/m)
  end

  ##
  ## Destructive version of #to_bool
  ##
  ##
  ## @see        #to_bool
  ##
  def to_bool!
    replace to_bool
  end

  ##
  ## Returns a bool representation of the string.
  ##
  ## @return     [Boolean] Bool representation of the object.
  ##
  def to_bool
    case self.force_encoding('utf-8')
    when /^[yt]/i
      true
    else
      false
    end
  end
end
