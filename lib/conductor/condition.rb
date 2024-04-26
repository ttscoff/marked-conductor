# frozen_string_literal: true

module Conductor
  class Condition
    def initialize(condition)
      @condition = condition
      @env = Conductor::Env.env
    end

    def true?
      parse_condition
    end

    def split_booleans(condition)
      split = condition.split(/ ((?:AND )?NOT|AND|OR) /)

      if split.count == 1
        test_condition(split[0])
      else
        res = nil
        bool = nil
        prev = false
        split.each do |cond|
          if cond =~ /((?:AND )?NOT|AND|OR)/
            bool = cond.bool_to_symbol
            next
          end

          r = split_booleans(cond)

          if bool == :and && (!r || !prev)
            res = false
          elsif bool == :or && (r || prev)
            return true
          elsif bool == :not && (r || prev)
            res = false
          else
            res = r
          end

          prev = res
        end
        res
      end
    end

    def test_operator(value1, value2, operator)
      case operator
      when :gt
        value1.to_f > value2.to_f
      when :lt
        value1.to_f < value2.to_f
      when :contains
        value1.to_s =~ /#{value2}/i
      when :starts_with
        value1.to_s =~ /^#{value2}/i
      when :ends_with
        value1.to_s =~ /#{value2}$/i
      when :not_equal
        value1 != value2
      when :equal
        value1 == value2
      end
    end

    def split_condition(condition)
      res = condition.match(/^(?<val1>.*?)(?:(?: +(?<op>(?:is|does)(?: not)?(?: an?|type(?: of)?|equals?(?: to))?|!?==?|[gl]t|(?:greater|less)(?: than)?|<|>|(?:starts|ends) with|(?:ha(?:s|ve) )?(?:prefix|suffix)|has|contains?|includes?) +)(?<val2>.*?))?$/i)
      [res['val1'], res['val2'], operator_to_symbol(res['op'])]
    end

    def test_type(val1, val2, operator)
      res = case val2
            when /array/i
              val1.is_a?(Array)
            when /(string|text)/i
              val1.is_a?(String)
            when /date/i
              val1.date?
            end
      operator == :type_of ? res : !res
    end

    def test_string(val1, val2, operator)
      return operator == :not_equal ? val1.nil? : !val1.nil? if val2.nil?

      return operator == :not_equal if val1.nil?

      val2 = val2.force_encoding('utf-8')

      if val1.date?
        if val2.time?
          date1 = val1.to_date
          date2 = val2.to_date
        else
          date1 = operator == :gt ? val1.to_day(:end) : val1.to_day
          date2 = operator == :gt ? val2.to_day(:end) : val1.to_day
        end

        res = case operator
              when :gt
                date1 > date2
              when :lt
                date1 < date2
              when :equal
                date1 == date2
              when :not_equal
                date1 != date2
              end
        return res unless res.nil?
      end

      val2 = if val2.strip =~ %r{^/.*?/$}
               val2.gsub(%r{(^/|/$)}, '')
             else
               Regexp.escape(val2)
             end
      val1 = val1.dup.to_s.force_encoding('utf-8')
      case operator
      when :contains
        val1 =~ /#{val2}/i
      when :not_starts_with
        val1 !~ /^#{val2}/i
      when :not_ends_with
        val1 !~ /#{val2}$/i
      when :starts_with
        val1 =~ /^#{val2}/i
      when :ends_with
        val1 =~ /#{val2}$/i
      when :equal
        val1 =~ /^#{val2}$/i
      when :not_equal
        val1 !~ /^#{val2}$/i
      else
        false
      end
    end

    def test_tree(origin, value, operator)
      return true if File.exist?(File.join(origin, value))

      dir = File.dirname(origin)

      if Dir.exist?(File.join(dir, value))
        true
      elsif [Dir.home, '/'].include?(dir)
        false
      else
        test_tree(dir, value, operator)
      end
    end

    def test_truthy(value1, value2, operator)
      return false unless value2&.bool?

      value2 = value2.to_bool if value2.is_a?(String)

      res = value1 == value2

      operator == :not_equal ? !res : res
    end

    def test_yaml(content, value, key, operator)
      yaml = YAML.safe_load(content.split(/^(?:---|\.\.\.)/)[1])

      return operator == :not_equal ? true : false unless yaml

      if key
        value1 = yaml[key]
        return operator == :not_equal ? true : false if value1.nil?

        value1 = value1.join(',') if value1.is_a?(Array)
        if %i[type_of not_type_of].include?(operator)
          test_type(value1, value, operator)
        elsif value1.bool?
          test_truthy(value1, value, operator)
        elsif value1.number? && value2.number? && %i[gt lt equal not_equal].include?(operator)
          test_operator(value1, value, operator)
        else
          test_string(value1, value, operator)
        end
      else
        res = value ? yaml.key?(value) : true
        operator == :not_equal ? !res : res
      end
    end

    def test_meta(content, value, key, operator)
      headers = []
      content.split(/\n/).each do |line|
        break if line == /^ *\n$/ || line !~ /\w+: *\S/

        headers << line
      end

      return operator == :not_equal if headers.empty?

      return operator != :not_equal if value.nil?

      meta = {}
      headers.each do |h|
        parts = h.split(/ *: */)
        k = parts[0].strip.downcase.gsub(/ +/, '')
        v = parts[1..].join(':').strip
        meta[k] = v
      end

      if key
        test_string(meta[key], value, operator)
      else
        res = value ? meta.key?(value) : true
        operator == :not_equal ? !res : res
      end
    end

    def test_condition(condition)
      type, value, operator = split_condition(condition)

      if operator.nil?
        return case type
               when /^(true|any|all|else|\*+|catch(all)?)$/i
                 true
               else
                 false
               end
      end

      case type
      when /^ext/i
        test_string(@env[:ext], value, operator) ? true : false
      when /^tree/i
        test_tree(@env[:origin], value, operator)
      when /^(path|dir)/i
        test_string(@env[:filepath], value, operator) ? true : false
      when /^phase/i
        test_string(@env[:phase], value, :starts_with) ? true : false
      when /^text/i
        test_string(IO.read(@env[:filepath]).force_encoding('utf-8'), value, operator) ? true : false
      when /^(yaml|headers|frontmatter)(?::(.*?))?$/i
        m = Regexp.last_match

        key = m[2] || nil

        content = IO.read(@env[:filepath]).force_encoding('utf-8')

        content.yaml? ? test_yaml(content, value, key, operator) : false
      when /^(mmd|meta(?:data)?)(?::(.*?))?$/i
        m = Regexp.last_match

        key = m[2] || nil

        content = IO.read(@env[:filepath]).force_encoding('utf-8')

        content.meta? ? test_meta(content, value, key, operator) : false
      else
        false
      end
    end

    def operator_to_symbol(operator)
      return operator if operator.nil?

      case operator
      when /(gt|greater( than)?|>|(?:is )?after)/i
        :gt
      when /(lt|less( than)?|<|(?:is )?before)/i
        :lt
      when /(ha(?:s|ve)|contains|includes|match(es)?|\*=)/i
        :contains
      when /not (suffix|ends? with)/i
        :not_ends_with
      when /not (prefix|(starts?|begins?) with)/i
        :not_starts_with
      when /(suffix|ends with|\$=)/i
        :ends_with
      when /(prefix|(starts?|begins?) with|\^=)/i
        :starts_with
      when /is not (an?|type( of)?)/i
        :not_type_of
      when /is (an?|type( of)?)/i
        :type_of
      when /((?:(?:is|does) )?not(?: equals?)?|!==?)/i
        :not_equal
      when /(is|==?|equals?)/i
        :equal
      end
    end

    def parse_condition
      cond = @condition.to_s.gsub(/\((.*?)\)/) do
        condition = Regexp.last_match(1)
        split_booleans(condition)
      end

      split_booleans(cond)
    end
  end
end
