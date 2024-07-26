# frozen_string_literal: true

require "tty-which"
require "yaml"
require "shellwords"
require "fcntl"
require "time"
require "chronic"
require "fileutils"
require "erb"
require_relative "conductor/version"
require_relative "conductor/env"
require_relative "conductor/config"
require_relative "conductor/hash"
require_relative "conductor/array"
require_relative "conductor/boolean"
require_relative "conductor/string"
require_relative "conductor/filter"
require_relative "conductor/script"
require_relative "conductor/command"
require_relative "conductor/condition"
require_relative "conductor/yui_compressor"

# Main Conductor module
module Conductor
  class << self
    attr_accessor :original_input
    attr_writer :stdin

    ##
    ## Return STDIN value, reading from STDIN if needed
    ##
    ## @return     [String] STDIN contents
    ##
    def stdin
      warn "input on STDIN required" unless $stdin.stat.size.positive? || $stdin.fcntl(Fcntl::F_GETFL, 0).zero?
      @stdin ||= $stdin.read.force_encoding("utf-8")
    end

    ##
    ## Execute commands/scripts in the track
    ##
    ## @param      track  The track
    ##
    ## @return     Resulting STDOUT output
    ##
    def execute_track(track)
      if track[:sequence]
        track[:sequence].each do |cmd|
          if cmd[:script]
            script = Script.new(cmd[:script])

            res = script.run
          elsif cmd[:command]
            command = Command.new(cmd[:command])

            res = command.run
          elsif cmd[:filter]
            filter = Filter.new(cmd[:filter])

            res = filter.process
          end

          Conductor.stdin = res unless res.nil?
        end
      elsif track[:script]
        script = Script.new(track[:script])

        Conductor.stdin = script.run
      elsif track[:command]
        command = Command.new(track[:command])

        Conductor.stdin = command.run
      elsif track[:filter]
        filter = Filter.new(track[:filter])

        Conductor.stdin = filter.process
      end

      Conductor.stdin
    end

    ##
    ## Main function to parse conditions and
    ##             execute actions. Executes recursively for
    ##             sub-tracks.
    ##
    ## @param      tracks     The tracks to process
    ## @param      res        The current result
    ## @param      condition  The current condition
    ##
    ## @return     [Array] result, matched condition(s)
    ##
    def conduct(tracks, res = nil, condition = nil)
      tracks.each do |track|
        cond = Condition.new(track[:condition])

        next unless cond.true?

        # Build "matched condition" message
        title = track[:title] || track[:condition]
        condition ||= [""]
        condition << title
        condition.push(track.key?(:continue) ? " -> " : ", ")

        res = execute_track(track)

        if track[:tracks]
          ts = track[:tracks]

          res, condition = conduct(ts, res, condition)

          next if res.nil?
        end

        break unless track[:continue]
      end

      if res == Conductor.original_input
        [nil, "No change in output"]
      else
        [res, condition]
      end
    end
  end
end
