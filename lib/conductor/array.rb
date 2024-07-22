# frozen_string_literal: true

class ::Array
  def symbolize_keys!
    replace symbolize_keys
  end

  def symbolize_keys
    map { |h| h.symbolize_keys }
  end

  def shell_join
    map { |p| Shellwords.join(p) }
  end

  def includes_file?(filename)
    inc = false
    each do |path|
      if path.join =~ /#{Regexp.escape(filename)}$/i
        inc = true
        break
      end
    end
    inc
  end

  def includes_frag?(frag)
    inc = false
    each do |path|
      if path.join =~ /#{Regexp.escape(frag)}/i
        inc = true
        break
      end
    end
    inc
  end
end
