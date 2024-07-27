# frozen_string_literal: true

# Hash helpers
class ::Hash
  ##
  ## Destructive version of #symbolize_keys
  ##
  ## @see        #symbolize_keys
  ##
  ## @return     [Hash] hash with keys as symbols
  ##
  def symbolize_keys!
    replace symbolize_keys
  end

  ##
  ## Convert all keys in hash to symbols. Works on nested hashes
  ##
  ## @see        #symbolize_keys!
  ##
  ## @return     [Hash] hash with keys as symbols
  ##
  def symbolize_keys
    each_with_object({}) { |(k, v), hsh| hsh[k.to_sym] = (v.is_a?(Hash) || v.is_a?(Array)) ? v.symbolize_keys : v }
  end
end
