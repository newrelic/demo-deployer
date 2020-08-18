require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/aws/validator"

describe "Infrastructure::Aws::Validator" do
  let(:resources) { [] }
  let(:type_validator_factory) { m = mock(); m.stubs(:create_validators); m }
  let(:app_config_provider) {
    m = mock();
    m.stubs(:get_aws_ec2_supported_sizes).returns([]);
    m.stubs(:get_aws_elb_max_listeners).returns(3);
    m.stubs(:get_resource_id_max_length).returns(10);
    m  }
  let(:validator) { Infrastructure::Aws::Validator.new(app_config_provider, type_validator_factory) }
  
  it "should create validator" do
    validator.wont_be_nil
  end

  it "should invoke type validator factory" do
    type_validator_factory.expects(:create_validators).returns([])
    validator.execute(resources)
  end

end
