# frozen_string_literal: true

# String helpers
class ::String
  ##
  ## Titlecase a string
  ##
  ## @return     Titleized string
  ##
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end

  def split_list
    split(/,/).map { |s| Shellwords.shellsplit(s) }
  end

  ##
  ## Normalize positional string to symbol
  ##
  ## @return     [Symbol] position symbol (:start, :h1, :h2, :end)
  ##
  def normalize_position
    case self
    when /^(be|s|t)/
      :start
    when /h1/
      :h1
    when /h2/
      :h2
    else
      :end
    end
  end

  ##
  ## Normalize a file include string to symbol
  ##
  ## @return     [Symbol] include type symbol (:code, :raw, :file)
  ##
  def normalize_include_type
    case self
    when /^c/
      :code
    when /^r/
      :raw
    else
      :file
    end
  end

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
    dup.force_encoding("utf-8") =~ /^\d{4}-\d{2}-\d{2}( \d{1,2}(:\d\d)? *([ap]m)?)?$/ ? true : false
  end

  ##
  ## Test a string to see if it includes a time
  ##
  ## @return     [Boolean] test result
  ##
  def time?
    dup.force_encoding("utf-8") =~ / \d{1,2}(:\d\d)? *([ap]m)?/i ? true : false
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

  ##
  ## Round a date string to a day
  ##
  ## @param      time [Symbol]  :start or :end
  ##
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
  ## Test if a string starts with Pandoc metadata
  ##
  ## @return     [Boolean] test result
  ##
  def pandoc?
    dup.force_encoding('utf-8').match?(/^% \S/m)
  end

  ##
  ## Returns a bool representation of the string.
  ##
  ## @return     [Boolean] Bool representation of the object.
  ##
  def to_bool
    case self.dup.force_encoding('utf-8')
    when /^[yt]/i
      true
    else
      false
    end
  end

  ##
  ## Convert a string to a regular expression
  ##
  ## If the string matches /xxx/, it will be interpreted
  ## directly as a regex. Otherwise it will be escaped and
  ## converted to regex.
  ##
  ## @return     [Regexp] Regexp representation of the string.
  ##
  def to_rx
    if self =~ %r{^/(.*?)/([im]+)?$}
      m = Regexp.last_match
      regex = m[1]
      flags = m[2]
      Regexp.new(regex, flags)
    else
      Regexp.new(Regexp.escape(self))
    end
  end

  ##
  ## Convert a string containing $1, $2 to a Regexp replace pattern
  ##
  ## @return     [String] Pattern representation of the object.
  ##
  def to_pattern
    gsub(/\$(\d+)/, '\\\\\1').gsub(/(^["']|["']$)/, "")
  end

  ##
  ## Discard invalid characters and output a UTF-8 String
  ##
  ## @return     [String] UTF-8 encoded string
  ##
  def utf8
    encode('utf-16', invalid: :replace).encode('utf-8')
  end

  ##
  ## Destructive version of #utf8
  ##
  ## @return     [String] UTF-8 encoded string, in place
  ##
  def utf8!
    replace scrub
  end

  ##
  ## Get a clean UTF-8 string by forcing an ISO encoding and then re-encoding
  ##
  ## @return     [String] UTF-8 string
  ##
  def clean_encode
    force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
  end

  ##
  ## Destructive version of #clean_encode
  ##
  ## @return     [String] UTF-8 string, in place
  ##
  def clean_encode!
    replace clean_encode
  end
end
