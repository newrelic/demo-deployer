require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/aws/type_validator_factory"

describe "Infrastructure::Aws::TypeValidatorFactory" do
  let(:resources) { [] }
  let(:supported_types) { {} }
  let(:app_config_provider) {
    m = mock();
    m.stubs(:get_aws_ec2_supported_sizes).returns([]);
    m.stubs(:get_aws_elb_max_listeners).returns(3);
    m  }
  let(:factory) { Infrastructure::Aws::TypeValidatorFactory.new(app_config_provider) }
  
  it "should create validator" do
    factory.wont_be_nil
  end

  it "should create empty array when no resources type" do
    factory.create_validators(resources).must_be_empty()
  end

  it "should allow supported type" do
    given_resource("host1", "ec2")
    factory.create_validators(resources).count.must_equal(1)
  end

  it "should create error validator when type is missing" do
    given_resource_without_type("hostname")
    validators = factory.create_validators(resources)

    result = validators[0].call()

    result.wont_be_empty()
    result.must_include("hostname")
  end

  def given_resource(id, type = nil)
    resources.push({"id"=> id, "type" => type})
  end

  def given_resource_without_type(id)
    resources.push({"id"=> id})
  end

end