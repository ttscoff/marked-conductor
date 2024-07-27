# frozen_string_literal: true

# True class
class ::TrueClass
  ##
  ## If TrueClass, it's a boolean
  ##
  ## @return     [Boolean] always true
  ##
  def bool?
    true
  end
end

# False class
class ::FalseClass
  ##
  ## If FalseClass, it's a boolean
  ##
  ## @return     [Boolean] always true
  ##
  def bool?
    true
  end
end
