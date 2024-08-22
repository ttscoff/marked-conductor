# frozen_string_literal: true
#
# This is a Ruby port of the YUI CSS compressor
# See LICENSE for license information

module YuiCompressor
  # Compress CSS rules using a variety of techniques
  class Yui
    attr_reader :input_size, :output_size

    ##
    ## Instantiate compressor
    ##
    ## @return     [Yui] self
    ##
    def initialize
      @preserved_tokens = []
      @comments = []
      @input_size = 0
      @output_size = 0
    end

    ##
    ## YUI Compress string
    ##
    ## @param      css          [String] The css
    ## @param      line_length  [Integer] The line length
    ##
    def compress(css, line_length = 0)
      @input_size = css.length

      css = process_comments_and_strings(css)

      # Normalize all whitespace strings to single spaces. Easier to work with that way.
      css.gsub!(/\s+/, " ")

      # Remove the spaces before the things that should not have spaces before them.
      # But, be careful not to turn "p :link {...}" into "p:link{...}"
      # Swap out any pseudo-class colons with the token, and then swap back.
      css.gsub!(/(?:^|\})[^{:]+\s+:+[^{]*\{/) do |match|
        match.gsub(":", "___PSEUDOCLASSCOLON___")
      end
      css.gsub!(/\s+([!{};:>+()\],])/, '\1')
      css.gsub!(/([!{}:;>+(\[,])\s+/, '\1')
      css.gsub!("___PSEUDOCLASSCOLON___", ":")

      # special case for IE
      css.gsub!(/:first-(line|letter)(\{|,)/, ':first-\1 \2')

      # no space after the end of a preserved comment
      css.gsub!(%r{\*/ }, "*/")

      # If there is a @charset, then only allow one, and push to the top of the file.
      css.gsub!(/^(.*)(@charset "[^"]*";)/i, '\2\1')
      css.gsub!(/^(\s*@charset [^;]+;\s*)+/i, '\1')

      # Put the space back in some cases, to support stuff like
      # @media screen and (-webkit-min-device-pixel-ratio:0){
      css.gsub!(/\band\(/i, "and (")

      # remove unnecessary semicolons
      css.gsub!(/;+\}/, "}")

      # Replace 0(%, em, ex, px, in, cm, mm, pt, pc) with just 0.
      css.gsub!(/([\s:])([+-]?0)(?:%|em|ex|px|in|cm|mm|pt|pc)/i, '\1\2')

      # Replace 0 0 0 0; with 0.
      css.gsub!(/:(?:0 )+0(;|\})/, ':0\1')

      # Restore background-position:0 0; if required
      css.gsub!(/(background-position|(?:(?:webkit|moz|o|ms)-)?transform-origin):0(;|\})/i) do
        "#{::Regexp.last_match(1).downcase}:0 0#{::Regexp.last_match(2)}"
      end

      # Replace 0.6 with .6, but only when preceded by : or a space.
      css.gsub!(/(:|\s)0+\.(\d+)/, '\1.\2')

      # Shorten colors from rgb(51,102,153) to #336699
      # This makes it more likely that it'll get further compressed in the next step.
      css.gsub!(/rgb\s*\(\s*([0-9,\s]+)\s*\)/) do |_match|
        "#".dup << ::Regexp.last_match(1).scan(/\d+/).map { |n| n.to_i.to_s(16).rjust(2, "0") }.join
      end

      # Shorten colors from #AABBCC to #ABC. Note that we want to make sure
      # the color is not preceded by either ", " or =. Indeed, the property
      #     filter: chroma(color="#FFFFFF");
      # would become
      #     filter: chroma(color="#FFF");
      # which makes the filter break in IE.
      css.gsub!(/([^"'=\s])(\s?)\s*#([0-9a-f])\3([0-9a-f])\4([0-9a-f])\5/i, '\1\2#\3\4\5')

      # border: none -> border:0
      css.gsub!(/(border|border-(top|right|bottom)|outline|background):none(;|\})/i) do
        "#{::Regexp.last_match(1).downcase}:0#{::Regexp.last_match(2)}"
      end

      # shorter opacity IE filter
      css.gsub!(/progid:DXImageTransform\.Microsoft\.Alpha\(Opacity=/i, "alpha(opacity=")

      # Remove empty rules.
      css.gsub!(%r{[^\};\{/]+\{\}}, "")

      if line_length.positive?
        # Some source control tools don't like it when files containing lines longer
        # than, say 8000 characters, are checked in. The linebreak option is used in
        # that case to split long lines after a specific column.
        start_index = 0
        idx = 0
        length = css.length
        while idx < length
          idx += 1
          if css[idx - 1, 1] == "}" && idx - start_index > line_length
            css = "#{css.slice(0, idx)}\n#{css.slice(idx, length)}"
            start_index = idx
          end
        end
      end

      # Replace multiple semi-colons in a row by a single one
      # See SF bug #1980989
      css.gsub!(/;+/, ";")

      # restore preserved comments and strings
      css = restore_preserved_comments_and_strings(css)

      # top and tail whitespace
      css.strip!

      @output_size = css.length
      css
    end

    ##
    ## Replace comments and strings with placeholders
    ##
    ## @param      css_text  [String] The css text
    ##
    ## @return [String] css text with strings replaced
    def process_comments_and_strings(css_text)
      css = css_text.dup.clean_encode

      start_index = 0
      token = ""
      totallen = css.length
      placeholder = ""

      # collect all comment blocks
      while (start_index = css.index(%r{/\*}, start_index))
        end_index = css.index(%r{\*/}, start_index + 2)
        end_index ||= totallen
        token = css.slice(start_index + 2..end_index - 1)
        @comments.push(token)
        css =  "#{css.slice(0..start_index + 1)}___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_#{@comments.length - 1}___#{css.slice(end_index, totallen)}"
        start_index += 2
      end

      # preserve strings so their content doesn't get accidentally minified
      css = css.gsub(/("([^\\"]|\\.|\\)*")|('([^\\']|\\.|\\)*')/) do |match|
        quote = match[0, 1]
        string = match.slice(1..-2)

        # maybe the string contains a comment-like substring?
        # one, maybe more? put'em back then
        if string =~ /___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_/
          @comments.each_index do |idx|
            string.gsub!(/___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_#{idx}___/, @comments[idx])
          end
        end

        # minify alpha opacity in filter strings
        string.gsub!(/progid:DXImageTransform\.Microsoft\.Alpha\(Opacity=/i, "alpha(opacity=")
        @preserved_tokens.push(string)

        "#{quote}___YUICSSMIN_PRESERVED_TOKEN_#{@preserved_tokens.length - 1}___#{quote}"
      end

      # # used to jump one index in loop
      # ie5_hack = false
      # strings are safe, now wrestle the comments
      @comments.each_index do |idx|
        # if ie5_hack
        #   ie5_hack = false
        #   next
        # end

        token = @comments[idx]
        placeholder = "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_#{idx}___"

        # ! in the first position of the comment means preserve
        # so push to the preserved tokens keeping the !
        if token[0, 1] == "!"
          @preserved_tokens.push(token)
          css.gsub!(/#{placeholder}/i, "___YUICSSMIN_PRESERVED_TOKEN_#{@preserved_tokens.length - 1}___")
          next
        end

        # # \ in the last position looks like hack for Mac/IE5
        # # shorten that to /*\*/ and the next one to /**/
        # if token[-1, 1] == "\\"
        #   @preserved_tokens.push("\\")
        #   css.gsub!(/#{placeholder}/, "___YUICSSMIN_PRESERVED_TOKEN_#{@preserved_tokens.length - 1}___")
        #   # keep the next comment but remove its content
        #   @preserved_tokens.push("")
        #   css.gsub!(/___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_#{idx + 1}___/,
        #             "___YUICSSMIN_PRESERVED_TOKEN_#{@preserved_tokens.length - 1}___")
        #   ie5_hack = true
        #   next
        # end

        # # keep empty comments after child selectors (IE7 hack)
        # # e.g. html >/**/ body
        # if token.empty? && (start_index = css.index(/#{placeholder}/)) &&
        #    (start_index > 2) && (css[start_index - 3, 1] == ">")
        #   @preserved_tokens.push("")
        #   css.gsub!(/#{placeholder}/, "___YUICSSMIN_PRESERVED_TOKEN_#{@preserved_tokens.length - 1}___")
        # end

        # in all other cases kill the comment
        css.gsub!(%r{/\*#{placeholder}\*/}, "")
      end

      css
    end

    ##
    ## Restore saved comments and strings
    ##
    ## @param      clean_css  [String] The processed css
    ##
    ## @return     [String] restored CSS
    ##
    def restore_preserved_comments_and_strings(clean_css)
      css = clean_css.clone
      css_length = css.length
      @preserved_tokens.each_index do |idx|
        # slice these back into place rather than regex, because
        # complex nested strings cause the replacement to fail
        placeholder = "___YUICSSMIN_PRESERVED_TOKEN_#{idx}___"
        start_index = css.index(placeholder, 0)
        next unless start_index # skip if nil

        end_index = start_index + placeholder.length

        css = css.slice(0..start_index - 1).to_s + @preserved_tokens[idx] + css.slice(end_index, css_length).to_s
      end

      css
    end
  end
end
