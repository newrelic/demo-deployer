require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/infrastructure/validator"

describe "Common" do
  describe "Validators" do
    describe "FieldExistValidator" do
      let(:items) { [] }
      let(:validator) { Common::Validators::FieldExistValidator.new("id")}
      
      it "should create validator" do
        validator.wont_be_nil
      end

      it "should allow item with id" do
          given_item("host1", "gws")
          validator.execute(items).must_be_nil()
      end    
      
      it "should not allow item with nil id" do
        given_item(nil, "gws")
        validator.execute(items).wont_be_nil()
        validator.execute(items).must_include("gws")
      end

      it "should not allow item without id" do
        given_item_without_id("gws")
        validator.execute(items).wont_be_nil()
        validator.execute(items).must_include("gws")
      end

      def given_item_without_id(provider = nil)
        items.push({"provider" => provider})
      end

      def given_item(id, provider = nil)
        items.push({"id"=> id, "provider" => provider})
      end

    end
  end
end