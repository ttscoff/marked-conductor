# frozen_string_literal: true

require 'spec_helper'

describe Conductor::Script do
  subject(:script) do
    Conductor::Script.new("bear-pro")
  end

  describe ".new" do
    it "makes a new Script instance" do
      expect(script).to be_a Conductor::Script
    end
  end

  describe ".path=" do
    it "sets script path" do
      expected = File.expand_path("~/.config/conductor/scripts/bear-pro")
      expect(script.path).to eq expected
      script.path = "multimarkdown"
      expect(script.path).to eq "/usr/local/bin/multimarkdown"
      script.path = "/usr/local/bin/multimarkdown"
      expect(script.path).to eq "/usr/local/bin/multimarkdown"

      expect { script.path = "flarglebutt" }.to raise_error(RuntimeError)
    end
  end

  describe ".args=" do
    it "sets script arguments" do
      script.args = ""
      expect(script.args).to eq ""
      script.args = []
      expect(script.args).to eq ""
    end
  end

  describe ".run" do
    it "runs the script on STDIN" do
      Conductor.stdin = "# Hello\n\nouch."
      expect(script.run).to eq  %(<h1>Hello</h1>\n<p>ouch.</p>\n)
      script.path = "/bin/cat"
      script.args = ["${file}"]
      expect(script.run).to match(/First, there seems to be a misconception/)
    end
  end
end
