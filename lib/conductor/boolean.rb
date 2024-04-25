# frozen_string_literal: true

# True class
class ::TrueClass
  def bool?
    true
  end
end

# False class
class ::FalseClass
  def bool?
    true
  end
end
