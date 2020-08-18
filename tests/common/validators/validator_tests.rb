require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/validator"

describe "Common::Validators::Validator" do
  let(:validators) { [] }
  let(:validator) { Common::Validators::Validator.new(validators) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate without any errors" do
    given_validator_passes()
    given_validator_passes()
    validator.execute().count.must_equal 0
  end

  it "should find single error" do
    given_validator_passes()
    given_validator_fails()
    given_validator_passes()
    validator.execute().count.must_equal 1
  end

  it "should find multiple errors" do
    given_validator_fails()
    given_validator_passes()
    given_validator_fails()
    given_validator_passes()
    given_validator_fails()
    given_validator_fails()
    validator.execute().count.must_equal 4
  end

  it "should validate composite validators" do
    given_validator_passes()
    given_composite_validator("error1", "erro2", nil, nil)
    validator.execute().count.must_equal 2
  end

  it "should validate multiple composite validators" do
    given_composite_validator("error1", "erro2", nil, nil)
    given_composite_validator(nil, nil, "error3", nil)
    given_validator_fails()
    validator.execute().count.must_equal 4
  end

  it "should allow composite validator returning no errors" do
    given_composite_validator_has_no_errors()
    given_validator_passes()
    validator.execute().count.must_equal 0
  end

  def given_composite_validator_has_no_errors(*errors)
    validators.push(lambda { return nil })
  end

  def given_composite_validator(*errors)
    sub_validators = []
    errors.each do |error|
      if error == nil
        sub_validators.push(lambda { return nil })
      else
        sub_validators.push(lambda { return error })
      end
    end
    validators.push(lambda { return Common::Validators::Validator.new(sub_validators).execute() })
  end

  def given_validator_passes()
    validators.push(lambda { return nil })
  end

  def given_validator_fails()
    validators.push(lambda { return "error!" })
  end

  def given_validator_throws()
    validators.push(lambda { raise "exception" })
  end

end