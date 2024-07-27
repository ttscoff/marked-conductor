# frozen_string_literal: true

require 'spec_helper'

describe ::Hash do
  describe ".symbolize_keys" do
    it "symbolizes hash keys" do
      expect({ "key" => "value" }.symbolize_keys).to eq({ key: "value" })
    end
  end

  describe ".symbolize_keys!" do
    it "symbolizes hash keys" do
      h = { "key" => "value" }
      expect(h.dup.symbolize_keys!).to eq({ key: "value" })
    end
  end
end

