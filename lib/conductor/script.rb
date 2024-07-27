# frozen_string_literal: true

module Conductor
  # Script runner
  class Script
    attr_reader :args, :path

    ##
    ## Initializes the given script.
    ##
    ## @param      script  The script/path
    ##
    def initialize(script)
      parts = Shellwords.split(script)
      self.path = parts[0]
      self.args = parts[1..].join(" ")
    end

    ##
    ## Set script path, automatically expands/tests
    ##
    ## @param      path  The path
    ##
    def path=(path)
      @path = if %r{^[~/.]}.match?(path)
                File.expand_path(path)
              else
                script_dir = File.expand_path("~/.config/conductor/scripts")
                if File.exist?(File.join(script_dir, path))
                  File.join(script_dir, path)
                elsif TTY::Which.exist?(path)
                  TTY::Which.which(path)
                else
                  raise "Path to #{path} not found"

                end
              end
    end

    ##
    ## Set the args array
    ##
    ## @param      array  The array
    ##
    def args=(array)
      @args = if array.is_a?(Array)
                array.join(" ")
              else
                array
              end
    end

    ##
    ## Execute the script
    ##
    ## @return     [String] script results (STDOUT)
    ##
    def run
      stdin = Conductor.stdin unless /\$\{?file\}?/.match?(args)

      raise "Script path not defined" unless @path

      raise "Script not executable" unless File.executable?(@path)

      use_stdin = true
      if /\$\{?file\}?/.match?(args)
        use_stdin = false
        args.sub!(/\$\{?file\}?/, Env.env[:filepath])
      else
        raise "No input" unless stdin

      end

      if use_stdin
        `echo #{Shellwords.escape(stdin)} | #{Env} #{@path} #{@args}`
      else
        `#{Env} #{@path} #{@args}`
      end
    end
  end
end
