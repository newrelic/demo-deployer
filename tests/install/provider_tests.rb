require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder"
require "./src/install/provider"
require "./src/services/definitions/service"
require "./src/provision/definitions/provisioned_resource"
require "./src/infrastructure/definitions/resource_data"

describe "Install::Provider" do

  let(:context_builder){ Tests::ContextBuilder.new() }

  it "should build" do
    given_provider()
    given_provider().wont_be_nil()
  end

  it "should create single service" do
    given_ec2_resource("apphost")
    given_service("app1", ["apphost"])
    given_provisioned_service("apphost", "1.2.3.4")
    services = given_provider().get_all()
    services.length.must_equal(1)
  end
  
  it "should not create when unprovisioned" do
    given_ec2_resource("apphost")
    given_service("app1", ["apphost"])
    service = given_provider().get_all()
    service.length.must_equal(0)
  end

  it "should not create when provisioned resource not found" do
    given_ec2_resource("apphost")
    given_service("app1", ["apphost"])
    given_provisioned_service("anotherhost", "1.2.3.4")
    service = given_provider().get_all()
    service.length.must_equal(0)
  end

  it "should create single service on multiple hosts" do
    given_ec2_resource("host1")
    given_ec2_resource("host2")
    given_service("app1", ["host1", "host2"])
    given_provisioned_service("host1", "1.1.1.1")
    given_provisioned_service("host2", "2.2.2.2")
    services = given_provider().get_all()
    services.length.must_equal(1)
  end
  
  it "should create multiple service on same host" do
    given_ec2_resource("host")
    given_service("app1", ["host"], 5000)
    given_service("app2", ["host"], 5001)
    given_provisioned_service("host", "1.1.1.1")
    services = given_provider().get_all()
    services.length.must_equal(2)
  end

  def given_service(service_id, destinations, port = 5000)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations)
  end

  def given_ec2_resource(id)
    context_builder.infrastructure().ec2(id, "t2.micro")
  end  

  def given_provisioned_service(id, ip)
    context_builder.provision().service_host(id, ip)
  end

  def given_provider()
    return @provider ||= create_provider()
  end

  def create_provider()
    context = context_builder.build()
    return Install::Provider.new(context)
  end


end
