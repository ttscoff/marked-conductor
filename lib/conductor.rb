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
require_relative "conductor/yui-compressor"

module Conductor
  class << self
    attr_accessor :original_input
    attr_writer :stdin

    def stdin
      warn "input on STDIN required" unless $stdin.stat.size.positive? || $stdin.fcntl(Fcntl::F_GETFL, 0).zero?
      @stdin ||= $stdin.read.force_encoding("utf-8")
    end
  end
end
