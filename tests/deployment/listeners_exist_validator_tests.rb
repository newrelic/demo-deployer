require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/definitions/service"
require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/deployment/listeners_exist_validator"


describe "Deployment::ListenersExistValidator" do
  let(:services) { [] }
  let(:resources) { [] }
  let(:validator) { Deployment::ListenersExistValidator.new(Infrastructure::Definitions::Aws::ElbResource) }

  it "should not error when no resources or services defined" do
    validator.execute(resources, services).must_be_nil()
  end

  it "should not error if services but no resources" do
    services.push(given_service())
    validator.execute(resources, services).must_be_nil()
  end

  it "should not error if no resources with listeners" do
    services.push(given_service())
    resources.push(given_ec2_resource())
    validator.execute(resources, services).must_be_nil()
  end

  it "should not error if listener exists" do
    services.push(given_service())
    resources.push(given_elb_resource())
    validator.execute(resources, services).must_be_nil()
  end

  it "should return an error if one resource listener is not defined" do
    services.push(given_service('app2'))
    resources.push(given_elb_resource(['app1']))

    errors = validator.execute(resources, services)
    errors.must_include('app1')
  end

  it "should return two errors if two resource listeners are not defined" do
    services.push(given_service('app1'), given_service('app2'))
    resources.push(given_elb_resource(['app3', 'app4']))

    errors = validator.execute(resources, services)
    errors.must_include("app3")
    errors.must_include("app4")
  end


  def given_elb_resource(listeners = ['app1'])
    id = 'host1'
    credential = 'XXXXXXXXXXX'
    user_name = 'username'

    resource = Infrastructure::Definitions::Aws::ElbResource.new(id, credential, listeners, user_name, [])
    return resource
  end

  def given_ec2_resource()
    id = 'host1'
    credential = 'XXXXXXXXXXX'
    size = 'micro'
    user_name = 'username'

    resource = Infrastructure::Definitions::Aws::Ec2Resource.new(id, credential, size, user_name, [])
    return resource
  end

  def given_service(service_id = 'app1')
    port = 5000
    destinations = ['host1']
    source_path = "src/path"
    deploy_script_path = "/deploy"
    display_name = service_id
    relationships = []
    endpoints = []

    service = Services::Definitions::Service.new(service_id, display_name, port, destinations, source_path, deploy_script_path, relationships, endpoints)
    return service
  end

end