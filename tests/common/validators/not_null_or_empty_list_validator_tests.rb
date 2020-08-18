require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/not_null_or_empty_list_validator"

describe "Common::Validators::NotNullOrEmptyListValidator" do
  let(:items) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:not_null_or_empty_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:validator) { Common::Validators::NotNullOrEmptyListValidator.new("fieldName", error_message, not_null_or_empty_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not allow nil" do
    given_item("fieldName", nil)
    not_null_or_empty_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should not allow empty" do
    given_item("fieldName", "")
    not_null_or_empty_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should not allow empty array" do
    given_item("fieldName", [])
    not_null_or_empty_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should not error when no elements" do
    validator.execute(nil).must_be_nil()
  end

  it "should allow no elements" do
    validator.execute(items).must_be_nil()
  end

  it "should allow string" do
    given_item("fieldName", "a string value")
    given_item("fieldName", "another string value")
    validator.execute(items).must_be_nil()
  end
  
  it "should allow integers" do
    given_item("fieldName", 123)
    given_item("fieldName", 456)
    validator.execute(items).must_be_nil()
  end
  
  it "should allow any objects" do
    given_item("fieldName", Object.new())
    validator.execute(items).must_be_nil()
  end
  
  it "should allow array with something in it" do
    given_item("fieldName", [432])
    validator.execute(items).must_be_nil()
  end
  
  def given_item(key, value = nil)
    if key.nil? == false && value.nil? == false
      items.push({key=> value})
    else
      items.push({})
    end
  end
end