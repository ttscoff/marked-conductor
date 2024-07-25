# frozen_string_literal: true

IRB.conf[:AUTO_INDENT] = true

require "irb/completion"
require_relative "lib/conductor"

include Conductor # standard:disable all

require "awesome_print"
AwesomePrint.irb!
