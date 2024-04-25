# frozen_string_literal: true

require 'tty-which'
require 'yaml'
require 'shellwords'
require 'fcntl'
require 'time'
require 'chronic'
require 'fileutils'
require_relative 'conductor/env'
require_relative 'conductor/config'
require_relative 'conductor/hash'
require_relative 'conductor/array'
require_relative 'conductor/boolean'
require_relative 'conductor/string'
require_relative 'conductor/script'
require_relative 'conductor/command'
require_relative 'conductor/condition'

module Conductor
  class << self
    def stdin
      @stdin ||= $stdin.read.strip.force_encoding('utf-8') if $stdin.stat.size.positive? || $stdin.fcntl(Fcntl::F_GETFL, 0).zero?
    end
  end
end
