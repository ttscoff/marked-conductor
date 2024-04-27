# frozen_string_literal: true

module Conductor
  # Command runner
  class Command
    attr_reader :args, :path

    def initialize(command)
      parts = Shellwords.split(command)
      self.path = parts[0]
      self.args = parts[1..].join(" ")
    end

    def path=(path)
      @path = if %r{^[%/]}.match?(path)
        File.expand_path(path)
      else
        which = TTY::Which.which(path)
        which || path
      end
    end

    def args=(array)
      @args = if array.is_a?(Array)
        array.join(" ")
      else
        array
      end
    end

    def run
      stdin = Conductor.stdin

      raise "Command path not found" unless @path

      use_stdin = true
      if /\$\{?file\}?/.match?(args)
        use_stdin = false
        args.sub!(/\$\{?file\}?/, %("#{Env.env[:filepath]}"))
      else
        raise "No input" unless stdin

      end

      if use_stdin
        `echo #{Shellwords.escape(stdin)} | #{Env} #{path} #{args}`
      else
        `#{Env} #{path} #{args}`
      end
    end
  end
end
