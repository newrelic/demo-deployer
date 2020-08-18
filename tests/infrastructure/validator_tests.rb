require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"

require "./src/infrastructure/validator"
require "./tests/orchestrator_tests"

describe "Infrastructure::Validator::execute" do
  let(:resources) { [] }
  let(:resource_id_validator) { m = mock(); m.stubs(:execute); m }
  let(:unique_id_validator) { m = mock(); m.stubs(:execute); m }
  let(:id_alphanumeric_validator) { m = mock(); m.stubs(:execute); m }
  let(:app_config_provider) {
    m = mock();
    m.stubs(:get_aws_ec2_supported_sizes).returns([]);
    m.stubs(:get_aws_elb_max_listeners).returns(3);
    m.stubs(:get_resource_id_max_length).returns(10);
    m  }
  let(:provider_validator_factory) { m = mock(); m.stubs(:create_validators).returns([]); m }
  let(:id_max_length) { 10 }
  let(:resource_id_length_validation) { Common::Validators::MaxLengthValidator.new("id", id_max_length, "Error") }

  let(:validator) { Infrastructure::Validator.new(
    app_config_provider,
    resource_id_validator,
    unique_id_validator,
    provider_validator_factory,
    id_alphanumeric_validator )}

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate resource_ids are present" do
    resource_id_validator.expects(:execute)
    validator.execute(resources)
  end

  it "should validate resource_ids are unique" do
    unique_id_validator.expects(:execute)
    validator.execute(resources)
  end

  it "should validate single provider" do
    provider_validator = mock(); provider_validator.expects(:execute)
    provider_validator_factory.expects(:create_validators).returns([lambda { return provider_validator.execute()} ])
    validator.execute(resources)
  end

  it "should validate multiple provider" do
    providerA = mock(); providerA.expects(:execute)
    providerB = mock(); providerB.expects(:execute)
    provider_validator_factory.expects(:create_validators).returns([lambda { return providerA.execute()}, lambda { return providerB.execute() } ])
    validator.execute(resources)
  end

  it "should validate resource id max length" do
    expect(validator.send(:get_resource_id_length_validator).execute(resources))
  end

  it "should validate id_alphanumeric_validator" do
    id_alphanumeric_validator.expects(:execute)
    validator.execute(resources)
  end

end