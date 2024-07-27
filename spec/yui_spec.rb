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
      yui = YuiCompressor::Yui.new
      expect(yui.compress(css_content, 60)).to match(/\{transition:transform 100ms ease-in-out\}/)
    end
  end
end
