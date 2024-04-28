# frozen_string_literal: true

require "irb/completion"
require_relative "lib/conductor"

include Conductor # standard:disable all

IRB.conf[:AUTO_INDENT] = true

require "awesome_print"
AwesomePrint.irb!
