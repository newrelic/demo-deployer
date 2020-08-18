require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/infrastructure/aws/r53ip/validator"

describe "Infrastructure::Aws::R53Ip::Validator" do
  let(:resources) { [] }
  let(:domain_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:at_least_one_validator) { m = mock(); m.stubs(:execute); m }
  let(:at_most_one_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Infrastructure::Aws::R53Ip::Validator.new(domain_exist_validator, at_least_one_validator, at_most_one_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should invoke domain exist validator" do
    domain_exist_validator.expects(:execute)
    validator.execute(resources)
  end
  
  it "should invoke at least one validator" do
    at_least_one_validator.expects(:execute)
    validator.execute(resources)
  end

  it "should invoke at most one validator" do
    at_most_one_validator.expects(:execute)
    validator.execute(resources)
  end
end