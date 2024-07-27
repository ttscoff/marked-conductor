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
    %w[insertFile(filename.md,start) insertStylesheet(filename.css) injectCSS(string) add_title addTitle(:h1) addTitle(y) injectScript(filename.js) prependFile(filename.txt) insert_toc insert_toc(3) insert_toc(3,h2) setMeta(key,value) setMeta(key) stripMeta stripMeta(title) setStyle(Ink) replaceAll(regex,pattern) replaceAll(regex) replace(regex,pattern) replace(regex) autolink fixHeaders].each do |f|
      filt = Conductor::Filter.new(f)

      it "outputs processed mmd content with filter #{f}" do
        Conductor.stdin = test_mmd_meta.dup
        expect(filt.process).to be_a String
      end

      it "outputs processed yaml content with filter #{f}" do
        Conductor.stdin = test_yaml_meta.dup
        expect(filt.process).to be_a String
      end

      it "outputs processed markdown content with filter #{f}" do
        Conductor.stdin = test_markdown.dup
        expect(filt.process).to be_a String
      end
    end
  end
end

