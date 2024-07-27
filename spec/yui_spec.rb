# frozen_string_literal: true

require 'spec_helper'

describe YuiCompressor::Yui do
  subject(:yui) do
    YuiCompressor::Yui.new
  end

  describe ".new" do
    it "makes a new Yui instance" do
      expect(yui).to be_a YuiCompressor::Yui
    end
  end

  describe ".compress" do
    it "outputs compressed CSS" do
      test_css
      yui = YuiCompressor::Yui.new
      css = IO.read("test_style.css")
      expect(yui.compress(css)).to match(/\{transition:transform 100ms ease-in-out\}/)
      delete_css
    end
  end
end
