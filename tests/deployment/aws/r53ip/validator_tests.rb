require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/aws/r53ip/validator"

describe "Deployment::Aws::R53Ip::Validator" do
  let(:resources) { [] }
  let(:services) { [] }
  let(:infrastructure_provider) { m = mock(); m.stubs(:execute); m }
  let(:allowed_listeners_validator) { m = mock(); m.stubs(:execute); m }
  let(:allowed_reference_validator) { m = mock(); m.stubs(:execute); m }
  let(:context) { m = mock(); m }
  let(:validator) { Deployment::Aws::R53Ip::Validator.new(services, context, allowed_listeners_validator, allowed_reference_validator) }

  it "should create validator" do
    validator.wont_be_nil()
  end

  it "should invoke allowed_listeners_validator" do
    allowed_listeners_validator.expects(:execute)
    validator.execute(resources).must_be_empty()
  end

  it "should invoke allowed_reference_validator" do
    allowed_reference_validator.expects(:execute)
    validator.execute(resources).must_be_empty()
  end
end