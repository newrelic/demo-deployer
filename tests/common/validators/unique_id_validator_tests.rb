require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/infrastructure/validator"

describe "Common" do
  describe "Validators" do
    describe "UniqueIdValidator" do
      let(:items) { [] }
      let(:validator) { Common::Validators::UniqueIdValidator.new("id")}
      
      it "should create validator" do
        validator.wont_be_nil
      end

      it "should allow distinct ids" do
        given_item("host1")
        given_item("anotherhost")
        given_item("localhost")
        validator.execute(items).must_be_nil()
      end
      
      it "should not allow same ids" do
        given_item("host1")
        given_item("anotherhost")
        given_item("host1")
        given_item("localhost")
        validator.execute(items).must_include("host1")
      end
      
      it "should not allow same ids case insensitive" do
        given_item("host1")
        given_item("anotherhost")
        given_item("HOST1")
        given_item("localhost")
        validator.execute(items).must_include("host1")
        validator.execute(items).must_include("HOST1")
      end

      def given_item(id)
        items.push({"id"=> id})
      end

    end
  end
end