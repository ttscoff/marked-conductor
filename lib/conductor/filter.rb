# frozen_string_literal: true

# String helpers
class ::String
  def normalize_filter
    parts = match(/(?<filter>[\w_]+)(?:\((?<paren>.*?)\))?$/i)
    filter = parts["filter"].downcase.gsub(/_/, "")
    params = parts["paren"]&.split(/ *, */)
    [filter, params]
  end

  def meta_type
    lines = split(/\n/)
    case lines[0]
    when /^--- *$/
      :yaml
    when /^ *[ \w]+: +\S+/
      :mmd
    else
      :none
    end
  end

  def meta_insert_point
    insert_point = 0

    case meta_type
    when :yaml
      lines = split(/\n/)
      lines.shift
      lines.each_with_index do |line, idx|
        next unless line =~ /^(...|---) *$/

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
    end

    insert_point
  end

  def first_h1
    first = 0
    split(/\n/).each_with_index do |line, idx|
      if line =~ /^(# *\S|={2,} *$)/
        first = idx
        break
      end
    end
    first
  end

  def first_h2
    first = 0
    split(/\n/).each_with_index do |line, idx|
      if line =~ /^(## *\S|-{2,} *$)/
        first = idx
        break
      end
    end
    first
  end

  def insert_toc(max = nil, after = :h1)
    lines = split(/\n/)
    max = max && max.to_i.positive? ? " max#{max}" : ""
    line = case after.to_sym
           when :h2
             first_h2.positive? ? first_h2 + 1 : 0
           when :h1
             first_h1.positive? ? first_h1 + 1 : 0
           else
             0
           end

    lines.insert(line, "\n<!--toc#{max}-->\n").join("\n")
  end

  def wrap_style
    if match(%r{<style>.*?</style>}m)
      self
    else
      "<style>#{self}</style>"
    end
  end

  def insert_css(path)
    path.sub!(/(\.css)?$/, '.css')

    if path =~ %r{^[~/]}
      path = File.expand_path(path)
    elsif File.directory?(File.expand_path("~/.config/conductor/css"))
      new_path = File.expand_path("~/.config/conductor/css/#{path}")
      path = new_path if File.exist?(new_path)
    elsif File.directory?(File.expand_path("~/.config/conductor/files"))
      new_path = File.expand_path("~/.config/conductor/files/#{path}")
      path = new_path if File.exist?(new_path)
    end

    if File.exist?(path)
      content = IO.read(path)
      yui = YuiCompressor::Yui.new
      content = yui.compress(content)
      lines = split(/\n/)
      insert_point = meta_insert_point
      insert_at = insert_point.positive? ? insert_point + 1 : 0
      lines.insert(insert_at, "#{content.wrap_style}\n\n")
      lines.join("\n")
    else
      warn "File not found (#{path})"
      self
    end
  end

  def insert_file(path, type = :file, position = :end)
    path.strip!

    if path =~ %r{^[~/]}
      path = File.expand_path(path)
    elsif File.directory?(File.expand_path("~/.config/conductor/files"))
      new_path = File.expand_path("~/.config/conductor/files/#{path}")
      path = new_path if File.exist?(new_path)
    end

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
      "#{out}\n#{self}"
    when :h1
      split(/\n/).insert(first_h1 + 1, out).join("\n")
    else
      "#{self}\n#{out}"
    end
  end

  def append(string)
    "#{self}\n#{string}"
  end

  def insert_script(path)
    path.strip!
    path = "#{path}.js" unless path =~ /\.js$/

    if path =~ %r{^[~/]}
      path = File.expand_path(path)
    else
      new_path = if File.directory?(File.expand_path("~/.config/conductor/javascript"))
                   File.expand_path("~/.config/conductor/javascript/#{path}")
                 elsif File.directory?(File.expand_path("~/.config/conductor/javascripts"))
                   File.expand_path("~/.config/conductor/javascripts/#{path}")
                 else
                   File.expand_path("~/.config/conductor/scripts/#{path}")
                 end

      path = new_path if File.exist?(new_path)
    end

    %(#{self}\n<script type="javascript" src="#{path}"></script>\n)
  end

  def title_from_slug
    filename = File.basename(Conductor::Env.env[:filepath]).sub(/\.[a-z]+$/i, "")
    filename.sub!(/-?\d{4}-\d{2}-\d{2}-?/, "")
    filename.sub!(/\bdot\b/, ".")
    filename.sub!(/ dash /, "-")
    filename
  end

  def get_title
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
    else
      m = match(/title: (.*?)$/i)
      title = m ? m[0] : nil
    end

    title ||= title_from_slug.titleize

    title
  end

  def insert_title
    title = get_title
    lines = split(/\n/)
    insert_point = meta_insert_point
    insert_at = insert_point.positive? ? insert_point + 1 : 0
    lines.insert(insert_at, "# #{title}\n")
    lines.join("\n")
  end

  def set_meta(key, value, style: :comment)
    case style
    when :yaml
      add_yaml(key, value)
    when :mmd
      add_mmd(key, value)
    else # comment or none
      add_comment(key, value)
    end
  end

  def add_yaml(key, value)
    sub(/^---.*?\n(---|\.\.\.)/m) do
      m = Regexp.last_match
      yaml = YAML.load(m[0])
      yaml[key] = value
      "#{YAML.dump(yaml)}\n---\n"
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
      lines.join("\n")
    end
  end

  def delete_mmd(key)
    sub(/^ *#{key}:.*?\n/i, "")
  end

  def has_comment?(key)
    match(/^<!--.*?#{key}: \S.*?-->/m)
  end

  def add_comment(key, value)
    if has_comment?(key)
      sub(/ *#{key}: .*?$/, "#{key}: #{value}")
    else
      lines = split(/\n/)
      lines.insert(meta_insert_point, "<!--\n#{key}: #{value}\n-->")
      lines.join("\n")
    end
  end

  def delete_meta(key)
    case meta_type
    when :yaml
      delete_yaml(key)
    when :mmd
      delete_mmd(key)
    end
  end

  def strip_meta
    case meta_type
    when :yaml
      sub(/^---.*?(---|...)/m, "")
    when :mmd
      lines = split(/\n/)
      lines[meta_insert_point..]
    end
  end

  def replace_all(regex, pattern)
    gsub(regex.to_rx, pattern.to_pattern)
  end

  def replace(regex, pattern)
    sub(regex.to_rx, pattern.to_pattern)
  end

  def to_rx
    if self =~ %r{^/(.*?)/([im]+)?$}
      m = Regexp.last_match
      regex = m[1]
      flags = m[2]
      Regexp.new(regex, flags)
    else
      Regexp.new(Regexp.escape(self))
    end
  end

  def to_pattern
    gsub(/\$(\d+)/, '\\\\\1').gsub(/(^["']|["']$)/, "")
  end
end

# String filtering
class Filter < String
  attr_reader :filter, :params

  def initialize(filter)
    @filter, @params = filter.normalize_filter
    super
  end

  def process
    content = Conductor.stdin

    case @filter
    when /(insert|add|inject)(css|style)/
      @params.each do |css|
        content = content.insert_css(css)
      end
      content
    when /(insert|add|inject)title/
      content.insert_title
    when /(insert|add|inject)script/
      content = content.append("\n\n<div>")
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
      max = @params.count.positive? ? @params[0] : nil

      if @params.count == 2
        after = @params[1] =~ /2/ ? :h2 : :h1
      else
        after = :start
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
      if @params&.count.positive?
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

      content.replace(@params[0], @params[1])
    end
  end
end
