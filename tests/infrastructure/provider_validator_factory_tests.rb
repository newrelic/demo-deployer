require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/infrastructure/validator"

describe "Infrastructure::ProviderValidatorFactory" do
  let(:resources) { [] }
  let(:supported_providers) { {} }
  let(:app_config_provider) {
    m = mock();
    m.stubs(:get_aws_ec2_supported_sizes).returns([]);
    m.stubs(:get_aws_elb_max_listeners).returns(3);
    m.stubs(:get_resource_id_max_length).returns(10);
    m  }
  let(:factory) { Infrastructure::ProviderValidatorFactory.new(app_config_provider) }

  it "should create factory" do
    factory.wont_be_nil
  end

  it "should create empty array when no resources provider" do
    factory.create_validators(resources).must_be_empty()
  end

  it "should create a provider validator" do
    given_resource("host1", "aws")
    factory.create_validators(resources).count.must_equal(1)
  end

  it "should create error validator when provider is missing" do
    given_resource_without_provider("host1")
    validators = factory.create_validators(resources)

    result = validators[0].call()

    result.wont_be_empty()
    result.must_include("Missing key")
    result.must_include("host1")
  end

  def given_resource(id, provider = nil)
    resources.push({"id"=> id, "provider" => provider})
  end

  def given_resource_without_provider(id)
    resources.push({"id"=> id})
  end

end