# frozen_string_literal: true

require 'spec_helper'

describe Conductor do
  describe ".conduct" do
    it "Runs conductor using config" do
      config = Conductor::Config.new
      config.configure
      Conductor.stdin = test_markdown
      tracks = config.tracks
      _, condition = Conductor.conduct(tracks)
      expect(condition).to include("Processing")
    end
  end
end

