# frozen_string_literal: true

require "spec_helper"

ENV["CONDUCTOR_TEST"] = "true"
Conductor::Env.env

describe Conductor::Env do
  describe ".load_test_env" do
    it "loads dummy data" do
      Conductor::Env.load_test_env
      expect(Conductor::Env.env[:home]).to eq "/Users/ttscoff"
    end
  end

  describe ".env" do
    it "loads data" do
      expect(Conductor::Env.env[:home]).to eq "/Users/ttscoff"
    end
  end

  describe ".env" do
    it "loads environment from variables" do
      file = File.expand_path("test/header_test.md")
      ENV["OUTLINE"] = "NONE"
      ENV["MARKED_ORIGIN"] = file
      ENV["MARKED_EXT"] = File.extname(file)
      ENV["MARKED_CSS_PATH"] = "/Applications/Marked 2.app/Contents/Resources/swiss.css"
      ENV["MARKED_PATH"] = file
      ENV["MARKED_INCLUDES"] = '"/Applications/Marked 2.app/Contents/Resources/tocstyle.css",' \
                               '"/Applications/Marked 2.app/Contents/Resources/javascript/main.js"'
      ENV["MARKED_PHASE"] = "PREPROCESS"
      ENV["CONDUCTOR_TEST"] = "false"
      expect(Conductor::Env.env).to be_a(Hash)
      expect(Conductor::Env.env[:includes]).to be_a(Array)
    end
  end

  describe ".to_s" do
    it "outputs environment as string" do
      ENV["CONDUCTOR_TEST"] = "true"
      expect(Conductor::Env.to_s).to match(/MARKED_CSS_PATH=/)
    end
  end
end
