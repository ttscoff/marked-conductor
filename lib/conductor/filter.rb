# frozen_string_literal: true

# String helpers
class ::String
  ##
  ## Search config folder for multiple subfolders and content
  ##
  ## @param      paths     [Array] The possible directory names
  ## @param      filename  [String] The filename to search for
  ## @param      ext       [String] The file extension
  ##
  def find_file_in(paths, filename, ext)
    return filename if File.exist?(filename)

    filename = File.basename(filename, ".#{ext}")

    paths.each do |path|
      exp = File.join(File.expand_path("~/.config/conductor/"), path, "#{filename}.#{ext}")
      return exp if File.exist?(exp)
    end

    "#{filename}.#{ext}"
  end

  ##
  ## Normalize the filter name and parameters, downcasing and removing spaces,
  ## underscores, splitting params by comma
  ##
  ## @return     [Array<String,Array>] array containing normalize filter and
  ##             array of parameters
  ##
  def normalize_filter
    parts = match(/(?<filter>[\w_]+)(?:\((?<paren>.*?)\))?$/i)
    filter = parts["filter"].downcase.gsub(/_/, "")
    params = parts["paren"]&.split(/ *, */)
    [filter, params]
  end

  ##
  ## Determine type of metadata (yaml, mmd, none)
  ##
  ## @return     [Symbol] metadata type
  ##
  def meta_type
    lines = split(/\n/)
    case lines[0]
    when /^--- *$/
      :yaml
    when /^ *[ \w]+: +\S+/
      :mmd
    when /^% +\S/
      :pandoc
    else
      :none
    end
  end

  ##
  ## Determine which line to use to insert after existing metadata
  ##
  ## @return     [Integer] line index
  ##
  def meta_insert_point
    insert_point = 0

    case meta_type
    when :yaml
      lines = split(/\n/)
      lines.shift
      lines.each_with_index do |line, idx|
        next unless line =~ /^(\.\.\.|---) *$/

        insert_point = idx + 1
        break
      end
    when :mmd
      lines = split(/\n/)
      lines.each_with_index do |line, idx|
        next if line =~ /^ *[ \w]+: +\S+/

        insert_point = idx
        break
      end
    when :pandoc
      lines = split(/\n/)
      lines.each_with_index do |line, idx|
        next if line =~ /^% +\S/

        insert_point = idx
        break
      end
    end

    insert_point
  end

  ##
  ## Locate the first H1 in the document
  ##
  ## @return     [Integer] index of first H1
  ##
  def first_h1
    first = nil
    split(/\n/).each_with_index do |line, idx|
      if line =~ /^(# *[^#]|={2,} *$)/
        first = idx
        break
      end
    end
    first
  end

  ##
  ## Locate the first H2 in the document
  ##
  ## @return     [Integer] index of first H2
  ##
  def first_h2
    first = nil
    meta_end = meta_insert_point
    split(/\n/).each_with_index do |line, idx|
      next if idx <= meta_end

      if line =~ /^(## *[^#]|-{2,} *$)/
        first = idx
        break
      end
    end
    first
  end

  ##
  ## Decrease all headers by given amount
  ##
  ## @param      amt   [Integer] The amount to decrease
  ##
  def decrease_headers(amt = 1)
    gsub(/^(\#{1,6})(?!=#)/) do
      m = Regexp.last_match
      level = m[1].size
      level -= amt
      level = 1 if level < 1
      "#" * level
    end
  end

  ##
  ## Increase all header levels by amount
  ##
  ## @param      amt   [Integer] number to increase by (1-5)
  ##
  ## @return     [String] content with headers increased
  ##
  def increase_headers(amt = 1)
    gsub(/^#/, "#{"#" * amt}#").gsub(/^\#{7,}/, "######")
  end

  ##
  ## Destructive version of #increase_headers
  ##
  ## @see        #increase_headers
  ##
  ## @param      amt   [Integer] The amount
  ##
  ## @return     [String] content with headers increased
  ##
  def increase_headers!(amt = 1)
    replace increase_headers(amt)
  end

  ##
  ## Insert a Table of Contents at given position
  ##
  ## @param      max    [Integer] The maximum depth of the TOC
  ## @param      after  [Symbol] Where to place TOC after (:top, :h1, :h2)
  ##
  ## @return     [String] content with TOC tag added
  ##
  def insert_toc(max = nil, after = :h1)
    lines = split(/\n/)
    max = max.to_i&.positive? ? " max#{max}" : ""
    line = case after.to_sym
           when :h2
             first_h2.nil? ? 0 : first_h2 + 1
           when :h1
             first_h1.nil? ? 0 : first_h1 + 1
           else
             meta_insert_point.positive? ? meta_insert_point + 1 : 0
           end

    lines.insert(line, "\n<!--toc#{max}-->\n").join("\n")
  end

  ##
  ## Wrap content in <style> tag if needed
  ##
  ## @return     [String] wrapped content
  ##
  def wrap_style
    if match(%r{<style>.*?</style>}m)
      self
    else
      "<style>#{self}</style>"
    end
  end

  ##
  ## Insert a <link> tag for the given path
  ##
  ## @param      path  [String] path to CSS files
  ##
  ## @return     [String] path with <style> link added
  ##
  def insert_stylesheet(path)
    path = find_file_in(%w[css styles], path, "css") unless path =~ /^http/
    inject_after_meta(%(<link rel="stylesheet" href="#{path.strip}">))
  end

  ##
  ## Insert raw CSS into the document, reading from a file and compressing
  ## contents
  ##
  ## @param      path  [String]  The CSS file path
  ##
  ## @return     [String] content with raw CSS injected
  ##
  def insert_css(path)
    return insert_stylesheet(path) if path.strip =~ /^http/

    path = path.sub(/(\.css)?$/, ".css")

    if path =~ %r{^[~/.]}
      path = File.expand_path(path)
    else
      path = find_file_in(%w[css styles files], path, "css")
    end

    if File.exist?(path)
      content = IO.read(path)
      yui = YuiCompressor::Yui.new
      content = yui.compress(content.force_encoding('utf-8'))
      inject_after_meta(content.wrap_style)
    else
      warn "File not found (#{path})"
      self
    end
  end

  ##
  ## Insert the given content after any existing metadata
  ##
  ## @param      content  [String] The content
  ##
  ## @return     [String] string with content injected
  ##
  def inject_after_meta(content)
    lines = split(/\n/)
    insert_point = meta_insert_point
    insert_at = insert_point.positive? ? insert_point + 1 : 0
    lines.insert(insert_at, "#{content}\n\n")
    lines.join("\n")
  end

  ##
  ## Insert a file include syntax for various types
  ##
  ## @param      path      [String] The file path
  ## @param      type      [Symbol] The type (:file, :code, :raw)
  ## @param      position  [Symbol] The position (:start, :h1, :h2, :end)
  ##
  def insert_file(path, type = :file, position = :end)
    path = path.strip

    path = if path =~ %r{^[.~/]}
             File.expand_path(path)
           else
             find_file_in(%w[files], path, File.extname(path))
           end

    warn "File not found: #{path}" unless File.exist?(path)

    out = case type
          when :code
            "<<(#{path})"
          when :raw
            "<<{#{path}}"
          else
            "<<[#{path}]"
          end
    out = "\n#{out}\n"

    case position
    when :start
      inject_after_meta(out)
    when :h1
      h1 = first_h1.nil? ? 0 : first_h1 + 1
      split(/\n/).insert(h1, out).join("\n")
    when :h2
      h2 = first_h2.nil? ? 0 : first_h2 + 1
      split(/\n/).insert(h2, out).join("\n")
    else
      "#{self}\n#{out}"
    end
  end

  ##
  ## Append string to self
  ##
  ## @param      string  [String] The string to append
  ##
  ## @return self with string appended
  ##
  def append(string)
    "#{self}\n#{string}"
  end

  ##
  ## Destructive version of #append
  ## @see        #append
  ##
  ## @return     self with string appended
  ##
  def append!(string)
    replace append(string)
  end

  ##
  ## Append a <script> tag for a given path
  ##
  ## @param      path  [String] The path
  ##
  ## @return     self with javascript tag appended
  ##
  def insert_javascript(path)
    %(#{self}\n<script type="javascript" src="#{path.strip}"></script>\n)
  end

  ##
  ## Append raw javascript
  ##
  ## @param      content  [String] The content
  ##
  ## @return     self with script tag containing contents appended
  ##
  def insert_raw_javascript(content)
    %(#{self}\n<script>#{content}</script>\n)
  end

  ##
  ## Insert javascript, detecting raw js and files, inserting appropriately
  ##
  ## Paths that are just a filename will be searched for in various .config
  ## directories. If found, a full path will be used.
  ##
  ## @param      path  [String] The path or raw content to inject
  ##
  def insert_script(path)
    path = path.strip
    orig_path = path

    return insert_javascript(path) if path =~ /^http/

    return insert_raw_javascript(path) if path =~ /\(.*?\)/

    path = if path =~ %r{^[~/.]}
             File.expand_path(path)
           else
             find_file_in(%w[javascript javascripts js scripts], path.sub(/(\.js)?$/, ".js"), "js")
           end

    if File.exist?(path)
      insert_javascript(path)
    else
      warn "Javascript not found: #{path}"
      insert_javascript(orig_path)
    end
  end

  def title_from_slug
    filename = File.basename(Conductor::Env.env[:filepath]).sub(/\.[a-z]+$/i, "")
    filename.sub!(/-?\d{4}-\d{2}-\d{2}-?/, "")
    filename.sub!(/\bdot\b/, ".")
    filename.sub!(/ dash /, "-")
    filename.gsub(/-/, ' ')
  end

  def read_title
    title = nil

    case meta_type
    when :yaml
      m = match(/^---.*?\n(---|\.\.\.)/m)
      yaml = YAML.load(m[0])
      title = yaml["title"]
    when :mmd
      split(/\n/).each do |line|
        if line =~ /^ *title: *(\S.*?)$/i
          title = Regexp.last_match(1)
          break
        end
      end
    when :pandoc
      title = nil
      split(/\n/).each do |line|
        if line =~ /^% +(.*?)$/
          title = Regexp.last_match(1)
          break
        end
      end
      title
    else
      m = match(/title: (.*?)$/i)
      title = m ? m[0] : nil
    end

    title ||= title_from_slug.titleize

    title
  end

  def insert_title(shift: 0)
    content = dup
    title = read_title
    content.increase_headers!(shift) if shift.positive?
    lines = content.split(/\n/)
    insert_point = content.meta_insert_point
    insert_at = insert_point.positive? ? insert_point + 1 : 0
    lines.insert(insert_at, "# #{title}\n")
    lines.join("\n")
  end

  def set_meta(key, value, style: :comment)
    case style
    when :yaml
      add_yaml(key, value)
    when :mmd
      add_mmd(key, value).ensure_mmd_meta_newline
    else # comment or none
      add_comment(key, value)
    end
  end

  def ensure_mmd_meta_newline
    split(/\n/).insert(meta_insert_point, "\n\n").join("\n")
  end

  def add_yaml(key, value)
    sub(/^---.*?\n(---|\.\.\.)/m) do
      m = Regexp.last_match
      yaml = YAML.load(m[0])
      yaml[key.gsub(/ /, "_")] = value
      "#{YAML.dump(yaml)}---\n"
    end
  end

  def delete_yaml(key)
    sub(/^---.*?\n(---|\.\.\.)/m) do
      m = Regexp.last_match
      yaml = YAML.load(m[0])
      yaml.delete(key)
      "#{YAML.dump(yaml)}\n---\n"
    end
  end

  def add_mmd(key, value)
    if match(/(\A|\n) *#{key}: *\S+/i)
      sub(/^ *#{key}:.*?\n/i, "#{key}: #{value}\n")
    else
      lines = split(/\n/)
      lines.insert(meta_insert_point, "#{key}: #{value}")
      "#{lines.join("\n")}\n"
    end
  end

  def delete_mmd(key)
    sub(/^ *#{key}:.*?\n/i, "")
  end

  def comment?(key)
    match(/^<!--.*?#{key}: \S.*?-->/m)
  end

  def add_comment(key, value)
    if comment?(key)
      sub(/ *#{key}: .*?$/, "#{key}: #{value}")
    else
      lines = split(/\n/)
      lines.insert(meta_insert_point + 1, "\n<!--\n#{key}: #{value}\n-->")
      lines.join("\n")
    end
  end

  def delete_meta(key)
    case meta_type
    when :yaml
      delete_yaml(key)
    when :mmd
      delete_mmd(key)
    else
      self
    end
  end

  def strip_meta
    case meta_type
    when :yaml
      sub(/^---.*?(---|\.\.\.)/m, "")
    when :mmd
      lines = split(/\n/)
      lines[meta_insert_point..].join("\n")
    when :pandoc
      lines = split(/\n/)
      lines[meta_insert_point..].join("\n")
    else
      gsub(/(\n|^)<!--\n[\w\d\s]+: ([\w\d\s]+)\n-->\n/m, '')
    end
  end

  def replace_all(regex, pattern)
    gsub(regex.to_rx, pattern.to_pattern)
  end

  def replace_one(regex, pattern)
    sub(regex.to_rx, pattern.to_pattern)
  end

  def autolink
    gsub(%r{(?mi)(?<!\(|\]: |"|')\b((?:[\w-]+?://)[-a-zA-Z0-9@:%._+~#=]{2,256}\b(?:[-a-zA-Z0-9@:%_+.~#?&/=]*))},
         '<\1>')
  end

  ##
  ## Count the number of h1 headers in the document
  ##
  ## @return     [Integer] Number of h1s.
  ##
  def count_h1s
    scan(/^#[^#]/).count
  end

  ##
  ## Normalize Setext headers to ATX
  ##
  ## @return [String] content with headers updated
  ##
  def normalize_headers
    gsub(/^(?<=\n\n|^)(\S[^\n]+)\n([=-]{2,})\n/) do
      m = Regexp.last_match
      case m[2]
      when /=/
        "# #{m[1]}\n\n"
      else
        "## #{m[1]}\n\n"
      end
    end
  end

  ##
  ## Destructive version of #normalize_headers
  ## @see        #normalize_headers
  ##
  ## @return     String with setext headers converted to ATX
  ##
  def normalize_headers!
    replace normalize_headers
  end

  ##
  ## Ensure there's at least one H1 in the document
  ##
  ## If no H1 is found, converts the lowest level header (first one) into an H1
  ##
  ## @return     [String] content with at least 1 H1
  ##
  def ensure_h1
    headers = to_enum(:scan, /(\#{1,6})([^#].*?)$/m).map { Regexp.last_match }
    return self if headers.select { |h| h[1].size == 1 }.count.positive?

    lowest_header = headers.min_by { |h| h[1].size }
    return self if lowest_header.nil?

    level = lowest_header[1].size - 1

    sub(/#{Regexp.escape(lowest_header[0])}/, "# #{lowest_header[2].strip}").decrease_headers(level)
  end

  ##
  ## Destructive version of #ensure_h1
  ##
  ## @see        #ensure_h1
  ##
  ## @return     Content with at least one H1
  ##
  def ensure_h1!
    replace ensure_h1
  end

  ##
  ## Bump all headers except for first H1
  ##
  ## @return     Content with adjusted headers
  ##
  def fix_headers
    return self if count_h1s == 1

    h1 = true

    gsub(/^(\#{1,6})([^#].*?)$/) do
      m = Regexp.last_match
      level = m[1].size
      content = m[2].strip
      if level == 1 && h1
        h1 = false
        m[0]
      else
        level += 1 if level < 6

        "#{"#" * level} #{content}"
      end
    end
  end

  ##
  ## Destructive version of #fix_headers
  ##
  ##
  ## @see        #fix_headers # #
  ##
  ## @return     [String] headers fixed #
  ##
  def fix_headers!
    replace fix_headers
  end

  ##
  ## Adjust header levels so there's no jump greater than 1
  ##
  ## @return     Content with adjusted headers
  ##
  def fix_hierarchy
    normalize_headers!
    ensure_h1!
    fix_headers!
    headers = to_enum(:scan, /(\#{1,6})([^#].*?)$/m).map { Regexp.last_match }
    content = dup
    last = 1
    headers.each do |h|
      level = h[1].size
      if level <= last + 1
        last = level
        next
      end

      level = last + 1
      content.sub!(/#{Regexp.escape(h[0])}/, "#{"#" * level} #{h[2].strip}")
    end

    content
  end
end

module Conductor
  # String filtering
  class Filter < String
    attr_reader :filter, :params

    ##
    ## Instantiate a filter
    ##
    ## @param      filter  [Filter] The filter
    ##
    def initialize(filter)
      @filter, @params = filter.normalize_filter
      super
    end

    ##
    ## Process STDIN with @filter
    ##
    ## @return     [String] processed text
    ##
    def process
      content = Conductor.stdin

      case @filter
      when /(insert|add|inject)stylesheet/
        @params.each do |sheet|
          content = content.insert_stylesheet(sheet)
        end
        content
      when /(insert|add|inject)(css|style)/
        @params.each do |css|
          content = content.insert_css(css)
        end
        content
      when /(insert|add|inject)title/
        amt = 0
        if @params
          amt = if @params[0] =~ /^[yts]/
                  1
                else
                  @params[0].to_i
                end
        end
        content.insert_title(shift: amt)
      when /(insert|add|inject)script/
        content.append!("\n\n<div>")
        @params.each do |script|
          content = content.insert_script(script)
        end
        "#{content}</div>"
      when /(prepend|append|insert|inject)(raw|file|code)/
        m = Regexp.last_match

        position = if @params.count == 2
                     @params[1].normalize_position
                   else
                     m[1].normalize_position
                   end
        content.insert_file(@params[0], m[2].normalize_include_type, position)
      when /inserttoc/
        max = @params.nil? || @params.empty? ? nil : @params[0]

        after = if @params && @params.count == 2
                  @params[1] =~ /2/ ? :h2 : :h1
                else
                  :start
                end

        content.insert_toc(max, after)
      when /(add|set)meta/
        unless @params.count == 2
          warn "Invalid filter parameters: #{@filter}(#{@params.join(",")})"
          return content
        end

        # needs to test for existing meta, setting key if exists, adding if not
        # should recognize yaml and mmd
        content.set_meta(@params[0], @params[1], style: content.meta_type)
      when /(strip|remove|delete)meta/
        if @params&.count&.positive?
          content.delete_meta(@params[0])
        else
          content.strip_meta
        end
      when /setstyle/
        # Should check for existing style first
        content.set_meta("marked style", @params[0], style: :comment)
      when /replaceall/
        unless @params.count == 2
          warn "Invalid filter parameters: #{@filter}(#{@params.join(",")})"
          return content
        end

        content.replace_all(@params[0], @params[1])
      when /replace$/
        unless @params.count == 2
          warn "Invalid filter parameters: #{@filter}(#{@params.join(",")})"
          return content
        end

        content.replace_one(@params[0], @params[1])
      when /(auto|self)link/
        content.autolink
      when /fix(head(lines|ers)|hierarchy)/
        content.fix_hierarchy
      else
        content
      end
    end
  end
end
