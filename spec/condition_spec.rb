# frozen_string_literal: true

require 'spec_helper'

describe Conductor::Condition do
  subject(:cond) do
    Conductor::Condition
  end

  describe ".new" do
    it "makes a new Condition instance" do
      expect(cond.new('filename ends with md')).to be_a Conductor::Condition
    end
  end

  describe ".true?" do
    it "tests condition" do
      ENV["CONDUCTOR_TEST"] = "true"
      c = cond.new("filename ends with md")
      expect(c.true?).to be true
    end
  end

  describe ".split_booleans" do
    it "splits and tests booleans" do
      ENV["CONDUCTOR_TEST"] = "true"
      c = cond.new("filename ends with md AND (has yaml OR has meta OR has pandoc OR parent contains .obsidian) AND NOT true")
      expect(c.split_booleans(c.condition)).to be false
    end
  end

  describe ".test_operator" do
    it "tests operators" do
      c = cond.new("filename ends with md")
      expect(c.test_operator(1, 2, :lt)).to be true
      expect(c.test_operator(1, 2, :gt)).to be false
      expect(c.test_operator(1, 2, :lt)).to be true
      expect(c.test_operator("a silly test", "silly", :contains)).to be_truthy
      expect(c.test_operator("a silly test", "silly", :not_contains)).to be false
      expect(c.test_operator("a silly test", "silly", :starts_with)).to be_falsy
      expect(c.test_operator("a silly test", "test", :ends_with)).to be_truthy
      expect(c.test_operator("test", "test", :equal)).to be true
      expect(c.test_operator("test", "test", :not_equal)).to be false
    end
  end

  describe ".operator_to_symbol" do
    it "tests operators" do
      c = cond.new("filename ends with md")
      operators = {
                    "greater than" => :gt,
                    "less than" => :lt,
                    "not contains file" => :not_includes_file,
                    "not contains path" => :not_includes_path,
                    "contains file" => :includes_file,
                    "contains path" => :includes_path,
                    "not matches" => :not_contains,
                    "matches" => :contains,
                    "has" => :contains,
                    "*=" => :contains,
                    "not ends with" => :not_ends_with,
                    "not begins with" => :not_starts_with,
                    "ends with" => :ends_with,
                    "begins with" => :starts_with,
                    "is not a" => :not_type_of,
                    "is a" => :type_of,
                    "does not equal" => :not_equal,
                    "!==" => :not_equal,
                    "equals" => :equal
                  }
      operators.each do |op, sym|
        expect(c.operator_to_symbol(op)).to eq sym
      end
    end
  end

  describe ".test_type" do
    it "tests types" do
      c = cond.new("filename ends with md")
      expect(c.test_type(1, "number", :type_of)).to be true
      expect(c.test_type(1, "integer", :type_of)).to be true
      expect(c.test_type(1.00, "float", :type_of)).to be true
      expect(c.test_type(%w[1], "array", :type_of)).to be true
      expect(c.test_type("test", "string", :type_of)).to be true
      expect(c.test_type('2021-04-12 14:00', "date", :type_of)).to be true
    end

    describe ".test_includes" do
      it "tests types" do
        includes = ["~/test/filename.md", "~/test/funky.md"]
        c = cond.new("filename ends with md")
        expect(c.test_includes(includes, "filename.md", :includes_file)).to be true
        expect(c.test_includes(includes, "filename2.md", :not_includes_file)).to be true
        expect(c.test_includes(includes, "test", :includes_path)).to be true
        expect(c.test_includes(includes, "funky", :not_includes_path)).to be false
        expect(c.test_includes(includes, "funky", :unknown)).to be false
      end
    end

    describe ".test_string" do
      it "tests types" do
        c = cond.new("filename ends with md")
        expect(c.test_string("2024-12-12", "2024-12-11", :gt)).to be true
        expect(c.test_string("2024-12-11 11pm", "2024-12-12 5pm", :lt)).to be true
        expect(c.test_string("2024-12-11 11:00", "2024-12-11 11:00", :equal)).to be true
        expect(c.test_string("2024-12-11 11:00", "2024-12-11 11:00", :not_equal)).to be false
        expect(c.test_string("once upon a time", "once", :not_starts_with)).to be false
        expect(c.test_string("once upon a time", "once", :not_ends_with)).to be true
        expect(c.test_string("once upon a time", "once", :not_equal)).to be true
        expect(c.test_string("once upon a time", "once", :unknown)).to be false
      end
    end

    describe ".test_tree" do
      it "tests for file in parent tree" do
        c = cond.new("filename ends with md")
        origin = File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "conductor", "string.rb"))
        expect(c.test_tree(origin, "hash.rb", :unknown)).to be true
        expect(c.test_tree(origin, "conductor", :unknown)).to be true
      end
    end

    describe ".test_truthy" do
      it "tests for truthiness" do
        c = cond.new("filename ends with md")
        expect(c.test_truthy(true, 'yes', :equal)).to be true
        expect(c.test_truthy(true, 'yes', :not_equal)).to be false
        expect(c.test_truthy(false, 'false', :equal)).to be true
        expect(c.test_truthy(false, 'false', :not_equal)).to be false
      end
    end

    describe ".test_yaml" do
      it "tests for yaml" do
        c = cond.new("filename ends with md")
        expect(c.test_yaml(test_yaml_meta, "Brett Terpstra", "author", :equal)).to be true
        expect(c.test_yaml(test_yaml_meta, "Brett Terpstra", "title", :not_equal)).to be true
        expect(c.test_yaml(test_yaml_meta, nil, "title", :equal)).to be true
        expect(c.test_yaml(test_yaml_meta, "string", "title", :type_of)).to be true
        expect(c.test_yaml(test_yaml_meta, true, "comments", :equal)).to be true
        expect(c.test_yaml(test_yaml_meta, 5, "value", :equal)).to be true
        expect(c.test_yaml(test_yaml_meta, "value", nil, :equal)).to be true
        expect(c.test_yaml(test_bad_yaml, "value", nil, :equal)).to be false
      end
    end

    describe ".test_meta" do
      it "tests for mmd meta" do
        c = cond.new("filename ends with md")
        expect(c.test_meta(test_mmd_meta, "Brett Terpstra", "author", :equal)).to be true
        expect(c.test_meta(test_mmd_meta, "Brett Terpstra", "title", :not_equal)).to be true
        expect(c.test_meta(test_mmd_meta, nil, "title", :equal)).to be true
        expect(c.test_meta(test_mmd_meta, "string", "title", :type_of)).to be true
        expect(c.test_meta(test_mmd_meta, true, "comments", :equal)).to be true
        expect(c.test_meta(test_mmd_meta, 5, "value", :equal)).to be true
        expect(c.test_meta(test_mmd_meta, "value", nil, :equal)).to be true
        expect(c.test_meta(test_bad_yaml, "value", nil, :equal)).to be false
      end
    end

    describe ".test_condition" do
      it "tests a condition" do
        c = cond.new("false")
        expect(c.test_condition("false")).to be false
      end
    end
  end
end
