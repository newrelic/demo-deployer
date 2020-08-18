require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/definitions/service"
require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/deployment/service_resource_same_type_validator"

describe "Deployment::ServiceResourceSameTypeValidator" do
  let(:services) { [] }
  let(:resources) { [] }
  let(:error_message) {"There is a validation error while testing"}
  let(:validator) { Deployment::ServiceResourceSameTypeValidator.new(error_message) }

  it "should NOT error when no resources or services defined" do
    validator.execute(resources, services).must_be_nil()
  end

  it "should NOT error if services but no resources" do
    services.push(given_service("app1"))
    validator.execute(resources, services).must_be_nil()
  end

  it "should NOT error when service use single resource" do
    services.push(given_service('app1', ["host1"]))
    resources.push(given_ec2_resource("host1"))
    validator.execute(resources, services).must_be_nil()
  end

  it "should NOT error when service use multiple resources of same type" do
    services.push(given_service('app1', ["host1", "host2"]))
    resources.push(given_ec2_resource("host1"))
    resources.push(given_ec2_resource("host2"))
    validator.execute(resources, services).must_be_nil()
  end

  it "should error when service use multiple resource of different type" do
    services.push(given_service('app1', ["host1", "resource2"]))
    resources.push(given_ec2_resource("host1"))
    resources.push(given_elb_resource("resource2"))
    result = validator.execute(resources, services)
    result.must_include(error_message)
    result.must_include("app1")
    result.must_include("elb")
    result.must_include("ec2")
  end

  it "should error when service use multiple resource of different type" do
    services.push(given_service('app1', ["host1"]))
    services.push(given_service('app2', ["resource2"]))
    resources.push(given_ec2_resource("host1"))
    resources.push(given_elb_resource("resource2"))
    validator.execute(resources, services).must_be_nil()
  end

  def given_elb_resource(id, listeners = ['app1'])
    credential = 'XXXXXXXXXXX'
    user_name = 'username'

    resource = Infrastructure::Definitions::Aws::ElbResource.new(id, credential, listeners, user_name, [])
    return resource
  end

  def given_ec2_resource(id)
    credential = 'XXXXXXXXXXX'
    size = 'micro'
    user_name = 'ec2-user'

    resource = Infrastructure::Definitions::Aws::Ec2Resource.new(id, credential, size, user_name, [])
    return resource
  end

  def given_service(service_id = 'app1', destinations = [])
    port = 5001
    source_path = "src/path"
    display_name = service_id
    deploy_script_path = "/deploy",
    relationships = []
    endpoints = []

    service = Services::Definitions::Service.new(service_id, display_name, port, destinations, source_path, deploy_script_path, relationships, endpoints)
    return service
  end

end