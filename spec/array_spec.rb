# frozen_string_literal: true

require 'spec_helper'

describe ::Array do
  describe ".symbolize_keys" do
    it "symbolizes hash keys" do
      expect([{ "key" => "value" }, { "key2" => "value" }].symbolize_keys).to eq([{ key: "value" }, { key2: "value" }])
    end
  end

  describe ".symbolize_keys!" do
    it "symbolizes hash keys" do
      h = [{ "key" => "value" }, { "key2" => "value" }]
      expect(h.dup.symbolize_keys!).to eq([{ key: "value" }, { key2: "value" }])
    end
  end

  describe ".shell_join" do
    it "joins items in an array" do
      h = [%w[one two], ["three four"]]
      expect(h.shell_join).to eq(["one two", "three\\ four"])
    end
  end

  describe ".includes_file?" do
    it "test for filename in array" do
      h = ["~/test/filename.md", "~/test/other.md"]
      expect(h.includes_file?("filename.md")).to be true
      expect(h.includes_file?("funky.md")).to be false
    end
  end

  describe ".includes_frag?" do
    it "test for fragment in array" do
      h = ["~/test/filename.md", "~/test/other.md"]
      expect(h.includes_frag?("test")).to be true
      expect(h.includes_frag?("funky")).to be false
    end
  end
end

