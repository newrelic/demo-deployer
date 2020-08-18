require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/alpha_numeric_list_validator"

describe "Common::Validators::AlphaNumericListValidator" do
  let(:items) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:alpha_numeric_list_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:validator) { Common::Validators::AlphaNumericListValidator.new("fieldName", error_message, alpha_numeric_list_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not allow nil" do
    given_item("fieldName", nil)
    alpha_numeric_list_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should not allow empty" do
    given_item("fieldName", "")
    alpha_numeric_list_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end

  it "should allow empty array" do
    given_item("fieldName", [])
    validator.execute(items).must_be_nil()
  end

  it "should not error when no elements" do
    validator.execute(nil).must_be_nil()
  end

  it "should allow no elements" do
    validator.execute(items).must_be_nil()
  end

  it "should not allow phrases" do
    given_item("fieldName", "a string value")
    given_item("fieldName", "another string value")
    alpha_numeric_list_validator.expects(:execute).returns("nope")
    validator.execute(items).must_include(error_message)
  end
  
  it "should allow alphanumeric" do
    given_item("fieldName", "abc123")
    given_item("fieldName", "456")
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