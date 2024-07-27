# frozen_string_literal: true

require 'spec_helper'

describe Conductor::Filter do
  subject(:filter) do
    Conductor::Filter.new("insertFile(./insert.md, h1)")
  end

  describe ".new" do
    it "makes a new Filter instance" do
      expect(filter).to be_a Conductor::Filter
    end
  end

  describe ".process" do
    it "outputs processed content" do
      Conductor.stdin = test_markdown.dup
      %w[insertFile(filename.md,start) insertStylesheet(filename.css) injectCSS(string) add_title addTitle(:h1) injectScript(filename.js) prependFile(filename.txt) insert_toc setMeta(key,value) stripMeta setStyle(Ink) replaceAll(regex,pattern) replace(regex,pattern) autolink fixHeaders].each do |f|
        filt = Conductor::Filter.new(f)
        expect(filt.process).to be_a String
      end
    end
  end
end

