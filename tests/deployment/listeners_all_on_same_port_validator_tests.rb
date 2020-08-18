require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/definitions/service"
require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/deployment/listeners_all_on_same_port_validator"

describe "Deployment::ListenersAllOnSamePortValidator" do
  let(:services) { [] }
  let(:resources) { [] }
  let(:validator) { Deployment::ListenersAllOnSamePortValidator.new(Infrastructure::Definitions::Aws::ElbResource) }

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

  it "should not error if single listener" do
    services.push(given_service())
    resources.push(given_elb_resource)
    validator.execute(resources, services).must_be_nil()
  end

  it "should not error if multiple listener same port" do
    services.push(given_service('app1', 5000))
    services.push(given_service('app2', 5000))
    services.push(given_service('app3', 5000))
    resources.push(given_elb_resource('app_elb', ['app3', 'app2', 'app3']))

    validator.execute(resources, services).must_be_nil()
  end

  it "should not error if multiple listener same port" do
    services.push(given_service('app1', 5000))
    services.push(given_service('app2', 5001))
    resources.push(given_elb_resource('app_elb', ['app1', 'app2']))

    validator.execute(resources, services).must_include('app_elb')
  end

  it "should not error if multiple listener same port" do
    services.push(given_service('app1', 5000))
    services.push(given_service('app2', 5001))
    resources.push(given_elb_resource('app_elb_1', ['app1', 'app2']))

    services.push(given_service('app3', 5000))
    services.push(given_service('app4', 5001))
    resources.push(given_elb_resource('app_elb_2', ['app3', 'app4']))

    results = validator.execute(resources, services)
    results.must_include('app_elb_1')
    results.must_include('app_elb_2')
  end

  def given_elb_resource(id = 'app_elb', listeners = ['app1'])
    credential = 'XXXXXXXXXXX'
    user_name = 'username'

    resource = Infrastructure::Definitions::Aws::ElbResource.new(id, credential, listeners, user_name, [])
    return resource
  end

  def given_ec2_resource()
    id = 'host1'
    credential = 'XXXXXXXXXXX'
    size = 'micro'
    user_name = 'ec2-user'

    resource = Infrastructure::Definitions::Aws::Ec2Resource.new(id, credential, size, user_name, [])
    return resource
  end

  def given_service(service_id = 'app1', port = 5000)
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