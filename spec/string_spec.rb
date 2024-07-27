# frozen_string_literal: true

require "spec_helper"

describe ::String do
  subject(:string) do
    test_markdown
  end

  subject(:mmd) do
    test_mmd_meta
  end

  subject(:yaml) do
    test_yaml_meta
  end

  subject(:pandoc) do
    test_pandoc_meta
  end

  describe ".titleize" do
    it "capitalizes a title" do
      ENV["CONDUCTOR_TEST"] = "true"
      expect(string.title_from_slug.titleize).to match(/Automating The Dim/)
    end
  end

  describe ".split_list" do
    it "splits string on comma and shell splits members" do
      expect(%(one, "--two three", -0 four five).split_list).to match_array([["--two three"], ["-0", "four", "five"], ["one"]])
    end
  end

  describe ".normalize_position" do
    it "convert position string to symbol" do
      expect("beginning".normalize_position).to eq :start
      expect("top".normalize_position).to eq :start
      expect("h1".normalize_position).to eq :h1
      expect("bottom".normalize_position).to eq :end
    end
  end

  describe ".normalize_include_type" do
    it "convert include type string to symbol" do
      expect("code".normalize_include_type).to eq :code
      expect("c".normalize_include_type).to eq :code
      expect("raw".normalize_include_type).to eq :raw
      expect("other".normalize_include_type).to eq :file
    end
  end

  describe ".bool_to_symbol" do
    it "convert boolean description to symbol" do
      expect("AND".bool_to_symbol).to eq :and
      expect("NOT".bool_to_symbol).to eq :not
      expect("!!".bool_to_symbol).to eq :not
      expect("OR".bool_to_symbol).to eq :or
    end
  end

  describe ".date?" do
    it "detect UTC dates" do
      expect("2004-12-21".date?).to be_truthy
      expect("ugly".date?).not_to be_truthy
    end
  end

  describe ".time?" do
    it "detect UTC dates" do
      expect("2004-12-21 3am".time?).to be_truthy
      expect("2004-12-21 12:00".time?).to be_truthy
      expect("2004-12-21".time?).not_to be_truthy
      expect("ugly".time?).not_to be_truthy
    end
  end

  describe ".to_date" do
    it "converts natural language to a date object" do
      expect("tomorrow at noon".to_date).to be_a Time
      expect("3pm".to_date).to be_a Time
      expect("no date info".to_date).not_to be_a Time
    end
  end

  describe ".strip_time" do
    it "removes time from date string" do
      expect("tomorrow at 3pm".strip_time).to eq "tomorrow at"
      expect("2024-12-12 14:00".strip_time).to eq "2024-12-12"
    end
  end

  describe ".to_day" do
    it "rounds a date to a day start or end" do
      expect("2024-12-12 3pm".to_day(:start).strftime('%H:%M')).to eq '00:00'
      expect("2024-12-12 3pm".to_day(:end).strftime('%H:%M')).to eq '23:59'
    end
  end

  describe ".number?" do
    it "detects a number" do
      expect("12345".number?).to be_truthy
      expect("1.5".number?).to be_truthy
      expect("one point five".number?).not_to be_truthy
    end
  end

  describe ".bool?" do
    it "detects a boolean" do
      expect("true".bool?).to be_truthy
      expect("no".bool?).to be_truthy
      expect("dunno".bool?).not_to be_truthy
    end
  end

  describe ".yaml?" do
    it "detects yaml" do
      expect(yaml.yaml?).to be_truthy
      expect("dunno".yaml?).not_to be_truthy
    end
  end

  describe ".meta?" do
    it "detects MMD metadata" do
      expect(mmd.meta?).to be_truthy
      expect("dunno".meta?).not_to be_truthy
    end
  end

  describe ".to_bool" do
    it "converts string to boolean" do
      expect("true".to_bool).to be_truthy
      expect("y".to_bool).to be_truthy
      expect("false".to_bool).not_to be_truthy
      expect("dunno".to_bool).not_to be_truthy
    end
  end

  describe ".to_rx" do
    it "converts string to regex" do
      expect('/\d+/'.to_rx).to be_a Regexp
      expect('/\d+/'.to_rx.to_s).to eq '(?-mix:\d+)'
      expect("not+a?regex".to_rx).to be_a Regexp
      expect("not+a?regex".to_rx).to eq (/not\+a\?regex/)
    end
  end

  describe ".to_pattern" do
    it "converts string to regex replace pattern" do
      expect('\1 to \2'.to_pattern).to eq '\1 to \2'
      expect("$1 to $2".to_pattern).to eq '\1 to \2'
    end
  end
end
