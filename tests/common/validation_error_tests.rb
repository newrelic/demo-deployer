require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/validation_error"

describe "Common::ValidationError" do
  let(:msg) { 'Validation Message'}
  let(:validation_errors) { [] }
  let(:validation_error) { Common::ValidationError.new(msg, validation_errors) }

  it "should create validation error" do
    validation_error.wont_be_nil
  end

  describe "with only general validation message" do
    it "should return validation message" do
      validation_error.to_s.must_include(msg)
    end
  end

  describe "with specific validation error messages" do
    let(:specific_validation_error) { 'Specific Validation Error' }
    let(:validation_errors) { [specific_validation_error] }

    it "should show specific validation errors" do
      validation_error.to_s.must_include(specific_validation_error)
    end
  end
end