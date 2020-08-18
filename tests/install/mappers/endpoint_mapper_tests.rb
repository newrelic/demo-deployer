require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/definitions/service"
require "./src/infrastructure/definitions/resource_data"
require "./src/provision/definitions/provisioned_resource"
require "./src/install/mappers/endpoint_mapper"

describe "Install::Mappers::EndpointMapper" do

  let(:logger) { m = mock(); m.stubs(:info); m.stubs(:debug); m.stubs(:error); m }
  let(:services_provider) { m = mock(); m }
  let(:provisioned_resources) { [] }
  let(:provision_provider) { m = mock(); m.stubs(:get_all).returns(provisioned_resources); m }
  let(:mapper) { Install::Mappers::EndpointMapper.new(services_provider, provision_provider)}
  let(:ip) { "1.1.1.1" }
  let(:ip2) { "2.2.2.2" }
  let(:port) { 80 }
  let(:host) { "host1" }
  let(:host2) { "host2" }
  let(:url) { "example.com" }
  let(:url2) { "demotron.newrelic.com" }
  let(:service_id) { "service1" }
  let(:params) {[]}
  let(:url_path) { "/inventory/1" }

  before do
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
  end

  it "should create" do
    mapper.wont_be_nil
  end

  it "should replace service with ip:port" do
    service = given_service(service_id, [host], ["[service:#{service_id}]"])
    given_host(host, ip, url)

    mapper.build_endpoint_map(service).must_include("http://#{ip}:#{port}")
  end

  it "should replace resource with url" do
    service = given_service(service_id, [host], ["[resource:#{host2}]"])

    given_host(host, ip, url)

    given_host(host2, ip2, url2)
    mapper.build_endpoint_map(service)[0].must_include(url2)
  end

  it "should not replace unknown service" do
    service = given_service('service_id', [host], ["service2"])
    service.stubs(:get_endpoints).returns(["[service:unknown]"])

    given_host(host, ip, url)

    mapper.build_endpoint_map(service).must_include("[service:unknown]")
  end

  it "should skip when no service or relationship url can be built" do
    service = given_service('service_id', [host], ["service2"])
    given_host(host, nil, nil)

    mapper.build_endpoint_map(service).must_include("service2")
  end

  it "should return endpoint with host ip" do
    endpoint_id = "service:#{service_id}"
    service = given_service(service_id, [host], ["[#{endpoint_id}]#{url_path}"])
    given_host(host, ip, nil)

    mapper.build_endpoint_map(service).must_include("http://#{ip}:#{port}#{url_path}")
  end

  it "should return endpoint with url" do
    endpoint_id = "service:#{service_id}"
    service = given_service(service_id, [host], ["[#{endpoint_id}]#{url_path}"])
    given_host(host, nil, url)

    mapper.build_endpoint_map(service).must_include("http://#{url}#{url_path}")
  end

  def given_service(id, hosts, endpoints)
    display_name = id
    service = Services::Definitions::Service.new(id, display_name, port, hosts, "/source_path", "/deploy", [], endpoints)
    services_provider.stubs(:get_services).returns([service])
    service.stubs(:get_port).returns(port)
    return service
  end

  def given_host(id, ip, url)
    resource = Infrastructure::Definitions::ResourceData.new(id, "gws", 1)
    resource.get_params().add("ip", ip)
    resource.get_params().add("url", url)
    provisioned_resource = Provision::Definitions::ProvisionedResource.new(resource)

    provisioned_resources.push(provisioned_resource)

    provision_provider.stubs(:get_by_id).with(id).returns(provisioned_resource)

    return provisioned_resource
  end

end