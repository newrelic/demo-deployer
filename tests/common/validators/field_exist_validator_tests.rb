require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/infrastructure/validator"

describe "Common" do
  describe "Validators" do
    describe "FieldExistValidator" do
      let(:items) { [] }
      let(:validator_string) { Common::Validators::FieldExistValidator.new("id")}
      let(:validator_symbol) { Common::Validators::FieldExistValidator.new(:id)}

      it "should create validator" do
        _(validator_string).wont_be_nil
      end

      it "should allow string item with string id" do
        given_item_string("host1", "gws")
        _(validator_string.execute(items)).must_be_nil()
      end

      it "should allow string item with symbol id" do
        given_item_string("host1", "gws")
        _(validator_symbol.execute(items)).must_be_nil()
      end

      it "should allow symbol item with string id" do
        given_item_symbol("host1", "gws")
        _(validator_string.execute(items)).must_be_nil()
      end

      it "should allow symbol item with symbol id" do
        given_item_symbol("host1", "gws")
        _(validator_symbol.execute(items)).must_be_nil()
      end

      it "should not allow string item with nil id" do
        given_item_string(nil, "gws")
        _(validator_string.execute(items)).wont_be_nil()
        _(validator_string.execute(items)).must_include("gws")
      end

      it "should not allow item without id" do
        given_item_without_id("gws")
        _(validator_string.execute(items)).wont_be_nil()
        _(validator_string.execute(items)).must_include("gws")
      end

      def given_item_without_id(provider = nil)
        items.push({"provider" => provider})
      end

      def given_item_string(id, provider = nil)
        items.push({"id"=> id, "provider" => provider})
      end

      def given_item_symbol(id, provider = nil)
        items.push({:id=> id, :provider => provider})
      end

    end
  end
end