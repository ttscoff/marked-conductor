# frozen_string_literal: true

unless ENV['CI'] == 'true'
  # SimpleCov::Formatter::Codecov # For CI
  require 'simplecov'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start
end

require "conductor"
require "cli-test"

# @old_setting = ENV["RUBYOPT"]

RSpec.configure do |c|
  c.formatter = 'd'
  c.expect_with(:rspec) { |e| e.syntax = :expect }

  c.before(:each) do |tst|
    ENV["RUBYOPT"] = "-W0"
    ENV["CONDUCTOR_TEST"] = "true"

    allow(FileUtils).to receive(:remove_entry_secure).with(anything)
    Conductor.stdin = test_markdown
  end

  c.after(:each) do
    # ENV["RUBYOPT"] = @old_setting
  end
end

def css_content
  <<~ENDCSS
    /* Just a comment */

    body {
      --bold-weight: 600;
      --bold-color: inherit;

      /* Relative font sizes */
      --font-smallest: 0.8em;
      --font-smaller: 0.875em;
      --font-small: 0.933em;
    }

    /*! A preserved comment? */

    .callout-fold::after {
      content: "This is a string? /* yep! */";
    }

    .callout-fold :pseudo {
      content: 'Fake';
      background-position:0;
      color: rgb(51,102,153);
      border: none;
    }

    .callout-fold .svg-icon {
      transition: transform 100ms ease-in-out;
    }

    .callout-fold.is-collapsed .svg-icon {
      transform: rotate(-90deg);
    }
  ENDCSS
end

def test_css
  File.open("test_style.css", "w") { |f| f.puts css_content }
end

def delete_css
  FileUtils.rm("test_style.css")
end

def test_markdown
  <<~EONOTE
    # Conductor Test

    ## Topic Balogna

    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
    nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
    eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
    sunt in culpa qui officia deserunt mollit anim id est laborum.

    ## Topic Banana

    This is just another topic.

    - It has a list in it
    - That's pretty fun, right?

    #### Topic Tropic

    Bermuda, Bahama, something something wanna.

    EOF
  EONOTE
end

def test_mmd_meta
  <<~EONOTE
    title: This is my document
    author: Brett Terpstra
    value: 5
    comments: true

    # Conductor Test

    Heyo.

    EOF
  EONOTE
end

def test_bad_yaml
  <<~EONOTE
    ---
    title: colon:
    author: another: gong!
    ---
    Bad YAML! Bad!
  EONOTE
end

def test_yaml_meta
  <<~EONOTE
    ---
    title: This is my document
    author: Brett Terpstra
    comments: true
    value: 5
    ---
    # Conductor Test

    ## an h2

    Heyo.

    EOF
  EONOTE
end

def test_pandoc_meta
  <<~EONOTE
    % This is my document
    % Brett Terpstra

    # Conductor Test

    Heyo.

    EOF
  EONOTE
end

def test_header_order
  <<~EONOTE
    # First

    ### Should be 2

    ## Should be huh?

    #### Should be 3
  EONOTE
end

def test_no_h1
  <<~EONOTE
    ### No H1

    #### Conductor Test

    Heyo.

    EOF
  EONOTE
end

def test_two_h1
  <<~EONOTE
    # First H1

    #### Conductor Test

    Heyo.

    # Second H1

    EOF
  EONOTE
end

def test_setext
  <<~EONOTE
    Header 1
    ========

    Header 2
    ---

    EOF
  EONOTE
end

def test_insert
  note = <<~INSERTED
    This is inserted text
  INSERTED
  File.open("insert.md", "w") { |f| f.puts note }
end

def delete_insert
  FileUtils.rm("insert.md")
end

def test_javascript
  File.open("test_script.js", "w") { |f| f.puts "void();" }
end

def delete_javascript
  FileUtils.rm("test_script.js")
end
