# frozen_string_literal: true

require 'spec_helper'

describe Conductor::Config do
  describe ".test_config" do
    config = Conductor::Config.new

    it "creates a new config file" do
      config_file = File.expand_path("./spec/test_config.yaml")
      config.config_file = config_file
      expect(config.configure).to eq false
      expect(config.configure).to eq true
      FileUtils.rm(config_file)
    end

    config = Conductor::Config.new
    config.configure
  end
end
