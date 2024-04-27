# frozen_string_literal: true

class ::Array
  def symbolize_keys!
    replace symbolize_keys
  end

  def symbolize_keys
    map { |h| h.symbolize_keys }
  end
end
