# frozen_string_literal: true

require 'spec_helper'

describe Conductor do
  describe ".conduct" do
    it "Runs conductor using config" do
      Conductor.stdin = test_markdown
      Conductor.original_input = test_markdown

      config = Conductor::Config.new
      config.config_file = File.expand_path('./spec/tracks.yaml')
      config.configure
      tracks = config.tracks
      _, condition = Conductor.conduct(tracks)
      expect(condition).to match(/No change in output/)
    end
  end

  def execute_tracks(tracks)
    out = test_markdown

    tracks.each do |track|
      Conductor.stdin = out.dup

      if track.key?(:tracks)
        out = execute_tracks(track[:tracks])
      else
        out = Conductor.execute_track(track)
      end
    end

    out
  end

  describe ".execute_track" do
    it "Runs tracks using config" do
      config = Conductor::Config.new
      config.config_file = File.expand_path('./spec/tracks.yaml')
      config.configure

      out = execute_tracks(config.tracks)
      expect(out).to be_a(String)
    end
  end
end
