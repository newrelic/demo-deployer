require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/max_length_validator"

describe "Common::Validators::MaxLengthValidator" do
  let(:items) { [] }
  let(:id_max_length) { 10 }
  let(:error_message) { "there was a significant error" }
  let(:validator) { Common::Validators::MaxLengthValidator.new("id", id_max_length, error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not trigger when nothing to validate" do
    validator.execute(nil)
  end

  it "should allow empty" do
    given_item_without_id()
    validator.execute(items).must_be_nil()
  end

  it "should allow up to max" do
    given_item("1234567890")
    validator.execute(items).must_be_nil()
  end

  it "should not allow greater than max" do
    given_item("12345678901")
    validator.execute(items).must_include(error_message)
    validator.execute(items).must_include("12345678901")
  end

  def given_item(id)
    items.push({"id"=> id})
  end

  def given_item_without_id()
    items.push({"another field" => "abc"})
  end

end