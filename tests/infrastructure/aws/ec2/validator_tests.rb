require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "./tests/context_builder.rb"

require "./src/infrastructure/aws/ec2/validator"

describe "Infrastructure::Aws::Ec2::Validator" do
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:resources) { [] }
  let(:size_validator) { m = mock(); m.stubs(:execute); m }
  let(:pem_key_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Infrastructure::Aws::Ec2::Validator.new(context, size_validator, pem_key_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should invoke type validator factory" do
    size_validator.expects(:execute)
    validator.execute(resources)
  end

  it "should invoke pem key validator factory" do
    pem_key_validator.expects(:execute)
    validator.execute(resources)
  end

end