require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/not_null_or_empty_validator"

describe "Common::Validators::NotNullOrEmptyValidator" do
  let(:error_message) { "there was a significant error" }
  let(:validator) { Common::Validators::NotNullOrEmptyValidator.new(error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should not allow nil" do
    validator.execute(nil).must_equal(error_message)
  end
    
  it "should not allow empty" do
    validator.execute("").must_equal(error_message)
  end

  it "should not allow empty array" do
    validator.execute([]).must_equal(error_message)
  end

  it "should allow string" do
    validator.execute("something").must_be_nil()
  end
  
  it "should allow array with something in it" do
    validator.execute([432]).must_be_nil()
  end
  
  it "should allow anything integer" do
    validator.execute(123).must_be_nil()
  end
  
  it "should allow any object" do
    validator.execute(Object.new()).must_be_nil()
  end

end