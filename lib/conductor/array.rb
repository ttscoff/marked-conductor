# frozen_string_literal: true

# Array helpers
class ::Array
  ##
  ## Destructive version of #symbolize_keys
  ##
  ## @see #symbolize_keys
  ##
  ## @return     [Array] symbolized arrays
  ##
  def symbolize_keys!
    replace symbolize_keys
  end

  ##
  ## Symbolize the keys of an array of hashes
  ##
  ## @return     [Array] array of hashes with keys converted to symbols
  ##
  def symbolize_keys
    map { |h| h.symbolize_keys }
  end

  ##
  ## Join components within an array
  ##
  ## @return     [Array] array of strings joined by Shellwords
  ##
  def shell_join
    map { |p| Shellwords.join(p) }
  end

  ##
  ## Test if any path in array matches filename
  ##
  ## @param      filename  [String] The filename
  ##
  ## @return     [Boolean] whether file is found
  ##
  def includes_file?(filename)
    inc = false
    each do |path|
      path = path.join if path.is_a?(Array)
      if path =~ /#{Regexp.escape(filename)}$/i
        inc = true
        break
      end
    end
    inc
  end

  ##
  ## Test if any path in an array contains any matching fragment
  ##
  ## @param      frag  [String] The fragment
  ##
  ## @return     [Boolean] whether fragment is found
  ##
  def includes_frag?(frag)
    inc = false
    each do |path|
      path = path.join if path.is_a?(Array)
      if path =~ /#{Regexp.escape(frag)}/i
        inc = true
        break
      end
    end
    inc
  end
end
