require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/aws/lambda/validator"

describe "Deployment::Aws::Lambda::Validator" do
  let(:resources) { [] }
  let(:services) { [] }
  let(:single_service_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Deployment::Aws::Lambda::Validator.new(services, single_service_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should invoke single_service_validator" do
    single_service_validator.expects(:execute)
    validator.execute(resources)
  end
end