# frozen_string_literal: true

module Conductor
  # Environment variables
  module Env
    ##
    ## Define @env using Marked environment variables
    ##
    def self.env
      if ENV["CONDUCTOR_TEST"].to_bool
        load_test_env
      else
        @env ||= {
          home: ENV["HOME"],
          css_path: ENV["MARKED_CSS_PATH"],
          ext: ENV["MARKED_EXT"],
          includes: ENV["MARKED_INCLUDES"].split_list,
          origin: ENV["MARKED_ORIGIN"],
          filepath: ENV["MARKED_PATH"],
          filename: File.basename(ENV["MARKED_PATH"]),
          phase: ENV["MARKED_PHASE"],
          outline: ENV["OUTLINE"],
          path: ENV["PATH"]
        }
      end

      @env
    end

    ##
    ## Loads a test environment.
    ##
    def self.load_test_env
      @env = {
        home: "/Users/ttscoff",
        css_path: "/Applications/Marked 2.app/Contents/Resources/swiss.css",
        ext: "md",
        includes: "".split_list,
        origin: "/Users/ttscoff/Sites/dev/bt/source/_posts/",
        filepath: "/Users/ttscoff/Sites/dev/bt/source/_posts/2024-04-01-automating-the-dimspirations-workflow.md",
        filename: "advanced-features.md",
        phase: "PROCESS",
        outline: "NONE",
        path: "/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Users/ttscoff/Sites/dev/bt/source/_posts"
      }
    end

    ##
    ## env to shell-compatible string
    ##
    ## @return     [String] shell-compatible string representation of @env
    ##
    def self.to_s
      {
        "HOME" => @env[:home],
        "MARKED_CSS_PATH" => @env[:css_path],
        "MARKED_EXT" => @env[:ext],
        "MARKED_ORIGIN" => @env[:origin],
        "MARKED_INCLUDES" => @env[:includes].shell_join.join(","),
        "MARKED_PATH" => @env[:filepath],
        "MARKED_PHASE" => @env[:phase],
        "OUTLINE" => @env[:outline],
        "PATH" => @env[:path]
      }.map { |k, v| %(#{k}="#{v}") }.join(" ")
    end
  end
end
