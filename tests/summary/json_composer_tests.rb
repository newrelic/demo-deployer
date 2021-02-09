require "json"

require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/summary/json_composer"
require "./src/install/definitions/installed_service"
require "./src/services/definitions/service"
require "./src/provision/definitions/provisioned_resource"
require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/infrastructure/definitions/aws/aws_resource"
require "./src/instrumentation/definitions/instrumentor"
require "./src/instrumentation/definitions/resource_instrumentor"
require "./src/instrumentation/definitions/service_instrumentor"
require "./src/instrumentation/definitions/global_instrumentor"

describe "Summary::JSONComposer" do
  let(:elb_id) { "elb1" }
  let(:elb_url) { "myelb.com" }
  let(:elb_resource) {
      p = Provision::Definitions::ProvisionedResource.new(Infrastructure::Definitions::Aws::ElbResource.new(elb_id, [], ["listener"], "username", {})) ;
      p.get_params().add("url", elb_url) ;
      p
    }
  let(:host) { "host1" }
  let(:host_resource_instance) { Infrastructure::Definitions::Aws::AwsResource.new(host, "ec4", {}, 1) }
  let(:host_resource) {
      p = Provision::Definitions::ProvisionedResource.new(host_resource_instance)
      p.get_params().add("ip", ip) ;
      p
    }
  let(:ip) { "1.1.1.1" }
  let(:app_id) { "service1" }
  let(:app_display_name) { "Service 1" }
  let(:port) { 5123 }
  let(:service1) {
    Install::Definitions::InstalledService.new(
      Services::Definitions::Service.new(app_id, app_display_name, port, [host], "/path/to/service/source", "/deploy", [], []),
      [host_resource]
    )
  }
  let(:services) { [] }
  let(:provisioned_resources) { [] }
  let(:resource_instrumentors) { [] }
  let(:service_instrumentors) { [] }
  let(:instrumentation_provider) { "newrelictesting" }
  let(:instrumented_resource) {
    instrumentor = Instrumentation::Definitions::ResourceInstrumentor.new("resource_instrumentor_id", instrumentation_provider, "1.86", "/path/to/service/source", "/deploy");
    instrumentor.set_item(host_resource_instance);
    instrumentor
  }
  let(:instrumented_service) {
    instrumentor = Instrumentation::Definitions::ServiceInstrumentor.new("service_instrumentor_id", instrumentation_provider, "3.4", "/path/to/service/source", "/deploy");
    instrumentor.set_item(service1);
    instrumentor
  }


  let(:global_instrumentors) { [] }
  let(:global1) { Instrumentation::Definitions::GlobalInstrumentor.new('id', instrumentation_provider, 'version', 'deploy_script_path', 'source_path') }
  let(:global2) { Instrumentation::Definitions::GlobalInstrumentor.new('id2', instrumentation_provider, 'version2', 'deploy_script_path', 'source_path') }
  let(:json_composer) { Summary::JSONComposer.new() }

  it "should verify json_composer execute returns global" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    given_global_instrumentor(global1)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["global"][0]["provider"].must_equal(instrumentation_provider)
  end

  it "should verify json_composer execute does not return global if it is not provided" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["global"].must_be_nil()
  end

  it "should verify json_composer execute returns more than one global" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    given_global_instrumentor(global1)
    given_global_instrumentor(global2)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["global"].length.must_equal(2)
  end

  it "should verify json_composer is created with no errors" do
    json_composer.wont_be_nil
  end

  it "should verify json_composer executes with no errors" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary.wont_be_empty()
  end

  it "should verify json_composer execute returns the host ip value" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["resources"][0]["access_point"]["ip"].must_equal(ip)
  end

  it "should verify json_composer execute returns service id" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["services"][0]["id"].must_equal(app_id)
  end

  it "should verify json_composer execute returns service url" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["services"][0]["urls"].must_include("http://#{ip}:#{port}")
  end

  it "should output resource url" do
    given_provisioned_resource(elb_resource)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["resources"][0]["access_point"]["url"].must_equal("http://#{elb_url}")
  end

  it "should output resource instrumentation provider" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    given_instrumented_resource(instrumented_resource)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["resources"][0]["instrumentation"][0]["provider"].must_equal(instrumentation_provider)
  end

  it "should output service instrumentation provider" do
    given_service(service1)
    given_provisioned_resource(host_resource)
    given_instrumented_service(instrumented_service)
    json_summary = json_composer.execute(provisioned_resources, services, resource_instrumentors, service_instrumentors, global_instrumentors)
    summary = JSON.parse(json_summary)
    summary["services"][0]["instrumentation"][0]["provider"].must_equal(instrumentation_provider)
  end

  def given_service(service)
    services.push(service)
  end

  def given_provisioned_resource(provisioned_resource)
    provisioned_resources.push(provisioned_resource)
  end

  def given_instrumented_resource(instrumented_resource)
    resource_instrumentors.push(instrumented_resource)
  end

  def given_instrumented_service(instrumented_service)
    service_instrumentors.push(instrumented_service)
  end

  def given_global_instrumentor(global_instrumentation)
    global_instrumentors.push(global_instrumentation)
  end

end
