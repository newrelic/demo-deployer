require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/instrumentation/validators/resource_validators"

describe "Instrumentation::Validators::ResourceValidators" do
  let(:instrumentors) { [] }
  let(:resource_ids) { [] }
  let(:target_exists_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Instrumentation::Validators::ResourceValidators.new(
    target_exists_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate the target exists" do
    target_exists_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids)
  end

end