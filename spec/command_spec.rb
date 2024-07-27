# frozen_string_literal: true

require 'spec_helper'

describe Conductor::Command do
  subject(:command) do
    Conductor::Command.new("pandoc -f markdown_gfm")
  end

  describe ".new" do
    it "makes a new Command instance" do
      expect(command).to be_a Conductor::Command
    end
  end

  describe ".path=" do
    it "sets command path" do
      expect(command.path).to eq "/usr/local/bin/pandoc"
      command.path = "~/bin/markdown"
      expect(command.path).to eq "/Users/ttscoff/bin/markdown"
      command.path = "multimarkdown"
      expect(command.path).to eq "/usr/local/bin/multimarkdown"
    end
  end

  describe ".args=" do
    it "sets command arguments" do
      command.args = ""
      expect(command.args).to eq ""
      command.args = []
      expect(command.args).to eq ""
    end
  end

  describe ".run" do
    it "runs the command on STDIN" do
      Conductor.stdin = "# Hello\n\nouch."
      command.path = "/usr/local/bin/multimarkdown"
      command.args = []
      expect(command.run).to eq  %(<h1 id="hello">Hello</h1>\n\n<p>ouch.</p>\n)
      command.args = "$file".dup
      expect(command.run).to match(/<p>First, there seems to be a misconception that/)
    end
  end
end
