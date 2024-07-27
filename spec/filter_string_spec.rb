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

  describe ".normalize_filter" do
    it "outputs array of filter and arguments" do
      filter1 = "insert_file"
      filter2 = "insertCSS(filename.css)"
      filter3 = "addmonster(cookie, monster)"
      expect(filter1.normalize_filter[0]).to match(/insertfile/)
      expect(filter1.normalize_filter).to match_array(["insertfile", nil])
      expect(filter2.normalize_filter[0]).to match(/insertcss/)
      expect(filter2.normalize_filter).to match_array(["insertcss", ["filename.css"]])
      expect(filter3.normalize_filter[0]).to match(/addmonster/)
      expect(filter3.normalize_filter).to match_array(["addmonster", %w[cookie monster]])
    end
  end

  describe ".meta_type" do
    it "Detects metadata type" do
      expect(mmd.meta_type).to eq :mmd
      expect(pandoc.meta_type).to eq :pandoc
      expect(yaml.meta_type).to eq :yaml
    end
  end

  describe ".meta_insert_point" do
    it "Detects metadata position" do
      expect(mmd.meta_insert_point).to eq 4
      expect(yaml.meta_insert_point).to eq 5
      expect(pandoc.meta_insert_point).to eq 2
    end
  end

  describe ".first_h1" do
    it "finds the first h1" do
      expect(test_no_h1.first_h1).to eq nil
      expect(string.first_h1).to eq 0
      expect(yaml.first_h1).to eq 6
    end
  end

  describe ".first_h2" do
    it "finds the first h2" do
      expect(test_no_h1.first_h2).to eq nil
      expect(string.first_h2).to eq 2
      expect(yaml.first_h2).to eq 8
    end
  end

  describe ".decrease_headers" do
    it "decreases all headers" do
      expect(test_no_h1.decrease_headers(1)).to match(/^## No H1/)
      expect(string.decrease_headers(2)).to match(/^# Conductor Test/)
    end
  end

  describe ".increase_headers" do
    it "increases all headers" do
      expect(test_no_h1.increase_headers(1)).to match(/^#### No H1/)
      expect(string.increase_headers(2)).to match(/^### Conductor Test/)
    end
  end

  describe ".insert_toc" do
    it "Inserts toc tag appropriately" do
      expect(string.insert_toc(3, :h1)).to match(/<!--toc max3-->/)
    end
  end

  describe ".append" do
    it "appends string" do
      expect(string.append("test append")).to match(/EOF\n\ntest append/)
      expect(string.dup.append!("test append")).to match(/EOF\n\ntest append/)
    end
  end

  describe ".inject_after_meta" do
    it "appends string" do
      expect(mmd.inject_after_meta("test append")).to match(/true\n\ntest append/)
      expect(yaml.inject_after_meta("test append")).to match(/---\ntest append/)
      expect(pandoc.inject_after_meta("test append")).to match(/Terpstra\n\ntest append/)
    end
  end

  describe ".wrap_style" do
    it "correctly wraps content in style tags" do
      string1 = "body{width:100%}"
      string2 = "<style>body{width:100%}</style>"
      expect(string1.wrap_style).to match(%r{<style>body\{width:100%\}</style>})
      expect(string2.wrap_style).to match(%r{<style>body\{width:100%\}</style>})
    end
  end

  describe ".insert_stylesheet" do
    it "correctly inserts style tag" do
      test_css
      expect(yaml.insert_stylesheet("./test_style.css")).to match(%r{---\n<link rel="stylesheet" href="./test_style.css">})
    end
  end

  describe ".insert_css" do
    it "outputs content with injected, compressed CSS" do
      content = test_markdown
      test_css
      expect(content.insert_css("./test_style.css")).to match(/\{transition:transform 100ms ease-in-out\}/)
      delete_css
    end
  end

  describe ".inject_after_meta" do
    it "outputs content with injected string" do
      expect(yaml.inject_after_meta("test inject")).to match(/---\ntest inject/)
      expect(mmd.inject_after_meta("test inject")).to match(/true\n\ntest inject/)
      expect(pandoc.inject_after_meta("test inject")).to match(/Terpstra\n\ntest inject/)
      expect(string.inject_after_meta("test inject")).to match(/^test inject/)
    end
  end

  describe ".insert_file" do
    it "inserts file include syntax in string" do
      # expect {
      #   ENV['RUBYOPT'] = '-W1'
      #   string.insert_file('not_exists.md')
      # }.to output(/not found/).to_stderr
      test_insert
      expect(string.insert_file("./insert.md", :file, :h2)).to match(/Balogna\n\n<<\[/)
      expect(yaml.insert_file("./insert.md", :file, :start)).to match(/---\n\n<<\[/)
      expect(yaml.insert_file("./insert.md", :code, :h2)).to match(/h2\n\n<<\(/)
      expect(string.insert_file("./insert.md", :raw, :h1)).to match(/Conductor Test\n\n<<\{/)
      delete_insert
    end
  end

  describe ".insert_javascript" do
    it "inserts a javascript tag" do
      expect(string.insert_javascript('test.js')).to match(%r{\n<script type="javascript" src="test.js"></script>\n\Z})
    end
  end

  describe ".insert_raw_javascript" do
    it "inserts a raw script tag" do
      expect(string.insert_raw_javascript('void();')).to match(%r{\n\n<script>void\(\);</script>\n\Z})
    end
  end

  describe ".insert_script" do
    it "inserts a raw script tag" do
      expect(string.insert_script('void();')).to match(%r{\n\n<script>void\(\);</script>\n\Z})
    end

    it "inserts a script tag" do
      expect(string.insert_script('https://brettterpstra.com/scripts/script.js')).to match(%r{\n<script type="javascript" src="https://brettterpstra.com/scripts/script.js"></script>\n\Z})
    end

    it "inserts a file reference" do
      test_javascript
      expect(string.insert_script('./test_script.js')).to match(%r{\n<script type="javascript" src=".*?test_script.js"></script>\n\Z})
      delete_javascript
    end
  end

  describe ".title_from_slug" do
    it "determines a correct title" do
      ENV["CONDUCTOR_TEST"] = "true"
      expect(string.title_from_slug).to match(/automating the dim/)
    end
  end

  describe ".read_title" do
    it "determines correct title" do
      ENV["CONDUCTOR_TEST"] = "true"
      expect(string.read_title).to match(/Automating The Dim/)
      expect(yaml.read_title).to match(/This is my document/)
      expect(mmd.read_title).to match(/This is my document/)
      expect(pandoc.read_title).to match(/This is my document/)
    end
  end

  describe ".insert_title" do
    it "inserts correct title" do
      ENV["CONDUCTOR_TEST"] = "true"
      expect(string.insert_title(shift: 1)).to match(/^# Automating The Dim/)
      expect(yaml.insert_title(shift: 1)).to match(/^# This is my document/)
    end
  end

  describe ".set_meta" do
    it "sets meta correctly based on type" do
      expect(string.set_meta("title", "Replaced title", style: string.meta_type)).to match(/^<!--\ntitle: Replaced/)
      expect(yaml.set_meta("title", "Replaced title", style: yaml.meta_type)).to match(/^---\ntitle: Replaced/)
      expect(mmd.set_meta("title", "Replaced title", style: mmd.meta_type)).to match(/^title: Replaced title\nauthor:/)
      key = "test_key"
      value = "test value"
      expect(yaml.set_meta(key, value, style: :yaml)).to match(/#{key}: #{value}/)
      expect(mmd.set_meta(key, value, style: :mmd)).to match(/#{key}: #{value}/)
      expect(string.set_meta(key, value, style: :comment)).to match(/<!--\n#{key}: #{value}\n-->/)
    end
  end

  describe ".add_yaml" do
    it "sets YAML meta correctly" do
      expect(yaml.add_yaml("test_key", "test value")).to match(/\ntest_key: test value\n/)
    end
  end

  describe ".delete_yaml" do
    it "deletes YAML meta correctly" do
      expect(yaml.delete_yaml("title")).not_to match(/\ntitle: This\n/)
    end
  end

  describe ".strip_meta" do
    it "deletes all metadata" do
      expect(yaml.strip_meta).not_to match(/^---.*?\n---/m)
      expect(mmd.strip_meta).not_to match(/^title:/)
      expect(pandoc.strip_meta).not_to match(/^% This is/)
      expect(string.strip_meta).to eq string
      expect(string.add_comment("title", "test title").strip_meta).to eq string.strip
    end
  end

  describe ".replace_all" do
    it "replaces all occurences" do
      expect(string.replace_all("Topic", "Turtle")).to match(/^## Turtle/)
      expect(string.replace_all('/(\w)opic/i', "$1urtle")).to match(/^## Turtle/)
    end
  end

  describe ".replace_one" do
    it "replaces one occurence" do
      res = string.replace_one('/(\w)opic/i', "$1urtle")
      expect(res).to match(/^## Turtle/)
      expect(res).to match(/^## Topic/)
    end
  end

  describe ".count_h1s" do
    it "counts the number of h1s" do
      expect(string.count_h1s).to eq 1
    end
  end

  describe ".normalize_headers" do
    it "converts setext headers to atx" do
      res = test_setext.normalize_headers
      expect(res).to match(/^# Header 1/)
      expect(res).to match(/^## Header 2/)
    end
  end

  describe ".ensure_h1" do
    it "ensures an h1 exists in the text" do
      res = test_no_h1.ensure_h1
      expect(res).to match(/^# No H1/)
      expect(res).to match(/^## Conductor/)
    end
  end

  describe ".fix_headers" do
    it "ensures h1 and increases other headers" do
      expect(test_no_h1.fix_headers).to match(/^#### No H1/)
    end
  end

  describe ".fix_hierarchy" do
    it "ensures header order is sane" do
      res = test_header_order.dup.fix_hierarchy
      expect(res).to match(/^## Should be 2/)
      expect(res).to match(/^### Should be 3/)
    end
  end
end
