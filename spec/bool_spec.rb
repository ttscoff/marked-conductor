# frozen_string_literal: true

require 'spec_helper'

describe TrueClass do
  describe ".bool?" do
    it "TrueClass is boolean" do
      expect(true.bool?).to be true
    end
  end
end

describe FalseClass do
  describe ".bool?" do
    it "FalseClass is boolean" do
      expect(false.bool?).to be true
    end
  end
end
