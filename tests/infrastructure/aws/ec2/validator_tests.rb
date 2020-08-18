require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/aws/ec2/validator"

describe "Infrastructure::Aws::Ec2::Validator" do
  let(:resources) { [] }
  let(:size_validator) { m = mock(); m.stubs(:execute); m }
  let(:aws_sizes_supported) { [] }
  let(:validator) { Infrastructure::Aws::Ec2::Validator.new(aws_sizes_supported, size_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should invoke type validator factory" do
    size_validator.expects(:execute)
    validator.execute(resources)
  end
end