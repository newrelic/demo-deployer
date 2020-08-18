require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/instrumentation/validators/service_validators"

describe "Instrumentation::Validators::ServiceValidators" do
  let(:instrumentors) { [] }
  let(:service_ids) { [] }
  let(:target_exists_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Instrumentation::Validators::ServiceValidators.new(
    target_exists_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate the target exists" do
    target_exists_validator.expects(:execute)
    validator.execute(instrumentors, service_ids)
  end

end