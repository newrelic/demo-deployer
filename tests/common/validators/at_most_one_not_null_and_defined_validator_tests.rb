require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/not_null_or_empty_validator"
require "./src/common/validators/at_most_one_not_null_and_defined_validator"

describe "Common::Validators::AtMostOneNotNullAndDefinedValidator" do
  let(:items) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:not_null_or_empty_validator) { 
    # Easier to test with the real validator here
    Common::Validators::NotNullOrEmptyValidator.new() 
  }
  let(:field_names) { [] }
  let(:validator) { Common::Validators::AtMostOneNotNullAndDefinedValidator.new(field_names, error_message, not_null_or_empty_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not error when no elements" do
    given_field_names("fieldName")
    validator.execute(nil).must_be_nil()
  end
  
  it "should not error when empty" do
    given_field_names("fieldName")
    validator.execute(items).must_be_nil()
  end
  
  it "should not error when missing" do
    given_field_names("fieldName", "anotherFieldName")
    given_item("id", "whatever")
    validator.execute(items).must_be_nil()
  end

  it "should not error when defined once and multiple items" do
    given_field_names("fieldName", "anotherFieldName")
    given_item("fieldName", "something")
    given_item("anotherFieldName", "anotherValue")
    validator.execute(items).must_be_nil()
  end
  
  it "should error when defined more than once" do
    given_field_names("fieldName", "anotherFieldName")
    given_two_value_item("fieldName", "something", "anotherFieldName", "anotherValue")
    error = validator.execute(items)
    error.wont_be_nil()
    error.must_include(error_message)
    error.must_include("fieldName")
    error.must_include("anotherFieldName")
  end

  it "should error when defined more than once for multiple items" do
    given_field_names("fieldName", "anotherFieldName")
    given_two_value_item("fieldName", "something", "anotherFieldName", "anotherValue")
    given_two_value_item("fieldName", "another item", "anotherFieldName", "another value for that other item")
    error = validator.execute(items)
    error.wont_be_nil()
    error.must_include(error_message)
    error.must_include("something")
    error.must_include("anotherValue")
    error.must_include("another item")
    error.must_include("another value for that other item")
  end

  def given_item(key, value)
    items.push({key=> value})
  end
  
  def given_two_value_item(key1, value1, key2, value2)
    items.push({key1=> value1, key2=> value2})
  end

  def create_item(key, value)
    item = {key=> value}
    return item
  end

  def given_field_names(*names)
    names.each do |name|
      field_names.push(name)
    end
  end
end