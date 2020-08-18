require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/at_least_one_not_null_or_empty_validator"

describe "Common::Validators::AtLeastOneNotNullOrEmptyValidator" do
  let(:items) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:not_null_or_empty_validator) { 
    m = mock(); 
    m.stubs(:execute).returns(nil);
    m }
  let(:field_names) { [] }
  let(:validator) { Common::Validators::AtLeastOneNotNullOrEmptyValidator.new(field_names, error_message, not_null_or_empty_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not allow undefined" do
    given_field_names("fieldName")
    given_item("fieldName", nil)
    validator.execute(items).must_include(error_message)
  end

  it "should not error when no elements" do
    given_field_names("fieldName")
    validator.execute(nil).must_be_nil()
  end

  it "should allow no elements" do
    given_field_names("fieldName")
    validator.execute(items).must_be_nil()
  end

  it "should allow string" do
    given_field_names("fieldName")
    given_item("fieldName", "a string value")
    given_item("fieldName", "another string value")
    validator.execute(items).must_be_nil()
  end
  
  it "should allow integers" do
    given_field_names("fieldName")
    given_item("fieldName", 123)
    given_item("fieldName", 456)
    validator.execute(items).must_be_nil()
  end
  
  it "should allow any objects" do
    given_field_names("fieldName")
    given_item("fieldName", Object.new())
    validator.execute(items).must_be_nil()
  end
  
  it "should allow array with something in it" do
    given_field_names("fieldName")
    given_item("fieldName", [432])
    validator.execute(items).must_be_nil()
  end
  
  it "should allow on 2 distinct key names" do
    given_field_names("vegie", "fruit")
    given_item("vegie", 12)
    given_item("fruit", "strawberry")
    validator.execute(items).must_be_nil()
  end
  
  it "should not allow on 2 distinct key names with one not defined" do
    given_field_names("vegie", "fruit")
    given_item("vegie", nil)
    given_item("fruit", "strawberry")
    result = validator.execute(items)
    result.must_include(error_message)
    result.must_include("vegie")
  end
  
  it "should not allow item missing all keys" do
    given_field_names("vegie", "fruit")
    given_item("vegie", 12)
    given_item("fruit", "strawberry")
    given_item("meat", "10 lbs")
    result = validator.execute(items)
    result.must_include(error_message)
    result.must_include("meat")
  end

  def given_item(key, value)
    items.push({key=> value})
    if value.nil?
      not_null_or_empty_validator.stubs(:execute).with(nil).returns(error_message); 
    end
    if value.kind_of?(String) && value.empty?
      not_null_or_empty_validator.stubs(:execute).with("").returns(error_message); 
    end
  end

  def given_field_names(*names)
    names.each do |name|
      field_names.push(name)
    end
  end
end