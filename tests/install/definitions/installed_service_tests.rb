require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/provision/definitions/provisioned_resource"
require "./src/services/definitions/service"
require "./src/infrastructure/definitions/resource_data"
require "./src/install/definitions/installed_service"

describe "Install::Definitions::InstalledService" do

  let(:installed_service){ nil }
  let(:provisioned_resources){ [] }

  before do
    @service = nil
  end

  it "should get id from service id" do
    given_service("app1", ["apphost"], 80)
    given_provisioned_resource("apphost", "1.2.3.4")
    id = when_get_id()
    id.must_equal("app1")
  end

  it "should build single service on single resource" do
    given_service("app1", ["apphost"], 80)
    given_provisioned_resource("apphost", "1.2.3.4")
    urls = when_get_urls()
    urls.length().must_equal(1)
    urls.first().must_equal("http://1.2.3.4:80")
  end
  
  it "should return empty when service undefined" do
    given_provisioned_resource("apphost", "1.2.3.4")
    urls = when_get_urls()
    urls.length().must_equal(0)
  end

  it "should return empty when no provisioned resource" do
    given_service("app1", ["apphost"], 80)
    urls = when_get_urls()
    urls.length().must_equal(0)
  end

  it "should return empty when resource not found" do
    given_service("app1", ["apphost"], 80)
    given_provisioned_resource("anotherhost", "1.2.3.4")
    urls = when_get_urls()
    urls.length().must_equal(0)
  end

  it "should return empty when no url/ip defined" do
    given_service("app1", ["apphost"], 80)
    given_provisioned_resource("apphost")
    urls = when_get_urls()
    urls.length().must_equal(0)
  end

  it "should return multiple url when hosted on multiple resources" do
    given_service("app1", ["host1", "host2"], 5000)
    given_provisioned_resource("host1", "1.1.1.1")
    given_provisioned_resource("host2", "2.2.2.2")
    urls = when_get_urls()
    urls.length().must_equal(2)
    urls[0].must_equal("http://1.1.1.1:5000")
    urls[1].must_equal("http://2.2.2.2:5000")
  end

  def given_service(id, destinations, port)
    display_name = id
    @service = Services::Definitions::Service.new(id, display_name, port, destinations || [], "/source_path", "/deploy", [], [])
  end

  def given_provisioned_resource(id, ip=nil, url=nil)
    resource = Infrastructure::Definitions::ResourceData.new(id, "test", 1)
    resource.get_params().add("ip", ip)
    resource.get_params().add("url", url)
    provisioned_resource = Provision::Definitions::ProvisionedResource.new(resource)
    provisioned_resources.push(provisioned_resource)
  end

  def when_get_urls()
    return get_installed_service().get_urls()
  end
  
  def when_get_id()
    return get_installed_service().get_id()
  end

  def get_installed_service()
    return installed_service ||= Install::Definitions::InstalledService.new(@service, provisioned_resources)
  end

end
