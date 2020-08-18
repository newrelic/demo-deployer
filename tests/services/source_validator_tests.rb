require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/source_validator"

describe "Services::SourceValidator" do
  let(:services) { [] }
  let(:at_least_one_not_null_or_empty_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:at_most_one_not_null_and_defined_validator) { m = mock(); m.stubs(:execute) ; m }  
  let(:supported_source_repository_validator) { m = mock(); m.stubs(:execute) ; m }  
  
  let(:validator) { Services::SourceValidator.new(
    at_least_one_not_null_or_empty_validator,
    at_most_one_not_null_and_defined_validator,
    supported_source_repository_validator
  )}

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate at least 1 service exist" do
    at_least_one_not_null_or_empty_validator.expects(:execute)
    validator.execute(services)
  end
  
  it "should validate at most 1 service exist" do
    at_most_one_not_null_and_defined_validator.expects(:execute)
    validator.execute(services)
  end

  it "should validate the repository source is supported" do
    supported_source_repository_validator.expects(:execute)
    validator.execute(services)
  end

end