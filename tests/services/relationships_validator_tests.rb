require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/services/relationships_validator"
require "./src/infrastructure/definitions/aws/elb_resource"

describe "Services::RelationshipsValidator" do
  let(:services) { [] }
  let(:resources) { [] }
  let(:aws_credential) {
    m = mock();
    m.stubs(:get_api_key);
    m.stubs(:get_secret_key);
    m.stubs(:get_region);
    m}
  let(:error_message) { "there was a significant error while running a test" }
  let(:validator) { Services::RelationshipsValidator.new(error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should be valid for single service not relationships" do
    given_service('service1', [])
    validator.execute(services, resources).must_be_nil()
  end

  it "should be valid for two services with valid relationships" do
    given_service('service1', ['service2'])
    given_service('service2', [])
    validator.execute(services, resources).must_be_nil()
  end

  it "should be invalid for when a service has invalid relationships" do
    given_service('service1', ['service2'])
    given_service('service2', ['not_a_service'])
    validator.execute(services, resources).must_include("not_a_service")
  end

  it "should be valid for when a service has an elb relationship" do
    given_service('service1', ['elb1'])
    given_service('service2', [])
    given_elb_resource('elb1', ['service2'])
    validator.execute(services, resources).must_be_nil()
  end

  it "should be valid for when a service has no valid relationships" do
    given_service('service1', ['doesnt_exist'])
    given_service('service2', [])
    given_elb_resource('elb1', ['service2'])
    validator.execute(services, resources).must_include("doesnt_exist")
  end

  def given_service(id, relationships)
    service = {}
    service["id"] = id
    service["relationships"] = relationships
    services.push(service)
  end

  def given_elb_resource(id, listeners, provider="aws", type="elb", user_name="username")
    resources.push(Infrastructure::Definitions::Aws::ElbResource.new(id, aws_credential, listeners, user_name, []))
  end

end
