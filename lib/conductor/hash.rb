# frozen_string_literal: true

class ::Hash
  def symbolize_keys!
    replace symbolize_keys
  end

  def symbolize_keys
    each_with_object({}) { |(k, v), hsh| hsh[k.to_sym] = (v.is_a?(Hash) || v.is_a?(Array)) ? v.symbolize_keys : v }
  end
end
