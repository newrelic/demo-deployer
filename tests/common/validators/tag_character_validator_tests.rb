require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/tag_character_validator"

describe "Common::Validators::TagCharacterValidator" do
  let(:items) { {} }
  let(:regex) { /\A[a-z\:]*\z/ }
  let(:validator) { Common::Validators::TagCharacterValidator.new() }

  it "should create validator" do
    validator.wont_be_nil
  end

  let(:a_key) { "validKey" }
  let(:a_value) { "valid value" }
  let(:invalid_string) { "+++++" }

  it "should not trigger when nil" do
    validator.execute(nil).must_be_empty()
  end

  it "should not trigger when nothing to validate" do
    validator.execute(items).must_be_empty()
  end

  it "should not trigger with valid key and value" do
    given_item(a_key, a_value)
    validator.execute(items).must_be_empty()
  end

  it "should trigger with invalid key" do
    given_item(invalid_string, a_value)
    errors = validator.execute(items)
    errors.count.must_equal(1)
    errors[0].must_include(invalid_string)
  end

  it "should not trigger with invalid value" do
    given_item(a_key, invalid_string)
    validator.execute(items).must_be_empty()
  end

  def given_item(key, value)
    items[key] = value
  end

end