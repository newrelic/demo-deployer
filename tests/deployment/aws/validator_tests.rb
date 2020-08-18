require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/aws/validator"
require "./tests/context_builder.rb"

describe "Deployment::Aws::Validator" do
  let(:resources) { [] }
  let(:services) { [] }
  let(:context) { Tests::ContextBuilder.new().build() }
  let(:type_validator_factory) { m = mock(); m.stubs(:create_validators).returns([]); m }
  let(:credential_exist_validator) { m = mock(); m.stubs(:execute); m }  
  let(:validator) { Deployment::Aws::Validator.new(services, context, type_validator_factory, credential_exist_validator) }
  
  it "should create validator" do
    validator.wont_be_nil
  end

  it "should invoke type validator factory" do
    type_validator_factory.expects(:create_validators).returns([])
    validator.execute(resources)
  end

  it "should execute credential_exist_validator" do
    credential_exist_validator.expects(:execute)
    validator.execute(resources)
  end

end
