require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/key_value_max_length_validator"

describe "Common::Validators::KeyValueMaxLengthValidator" do
  let(:items) { {} }
  let(:key_max_length) { 10 }
  let(:value_max_length) { 10 }
  let(:error_message) { "there was a significant error" }
  let(:validator) { Common::Validators::KeyValueMaxLengthValidator.new(key_max_length, value_max_length, error_message) }

  let(:a_key) { "key" }
  let(:a_value) { "value" }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not trigger when nothing to validate" do
    validator.execute(nil)
  end

  it "should allow nil key" do
    given_item(nil, a_value)
    validator.execute(items).must_be_nil()
  end

  it "should allow nil value" do
    given_item(a_key, nil)
    validator.execute(items).must_be_nil()
  end

  it "should allow up to max key" do
    key = given_legth_string('a', key_max_length)
    given_item(key, a_value)
    validator.execute(items).must_be_nil()
  end

  it "should allow up to max value" do
    value = given_legth_string('b', value_max_length)
    given_item(a_key, value)
    validator.execute(items).must_be_nil()
  end

  it "should not allow greater than max key" do
    key = given_legth_string('c', key_max_length+1)
    given_item(key, a_value)
    validator.execute(items).must_include(error_message)
    validator.execute(items).must_include(key)
  end

  it "should not allow greater than max value" do
    value = given_legth_string('d', value_max_length+1)
    given_item(a_key, value)
    validator.execute(items).must_include(error_message)
    validator.execute(items).must_include(value)
  end

  it "should not allow greater than max key/value" do
    key = given_legth_string('e', key_max_length+1)
    value = given_legth_string('f', value_max_length+1)
    given_item(key, value)
    validator.execute(items).must_include(error_message)
    validator.execute(items).must_include(key)
    validator.execute(items).must_include(value)
  end

  def given_item(key, value)
    items[key] = value
  end

  def given_legth_string(repeat, length)
    output = ""
    while output.length < length
      output += repeat
    end
    return output
  end

end