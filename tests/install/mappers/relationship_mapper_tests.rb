require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/definitions/resource_data"
require "./src/services/definitions/service"
require "./src/install/mappers/relationship_mapper"

describe "Install::Mappers::RelationshipMapper" do
  let(:app1) { "app1" }
  let(:app2) { "app2" }
  let(:app3) { "app3" }
  let(:host1) { "host1" }
  let(:host2) { "host2" }
  let(:host3) { "host3" }
  let(:elb1) { "elb1" }
  let(:port) { 80 }
  let(:ip1) { "1.1.1.1"}
  let(:ip2) { "2.2.2.2"}
  let(:ip3) { "3.3.3.3"}
  let(:ip4) { "4.4.4.4"}
  let(:url) { "example.com"}
  let(:url1) { "http://#{ip1}:#{port}"}
  let(:url2) { "http://#{ip2}:#{port}"}
  let(:url3) { "http://#{ip3}:#{port}"}
  let(:url4) { "http://#{ip4}:#{port}"}
  let(:empty_relationships) { [] }
  let(:services_provider) { m = mock(); m }
  let(:provision_provider) { m = mock(); m }
  let(:mapper) { Install::Mappers::RelationshipMapper.new(services_provider, provision_provider)}
  let(:params) {[]}

  it "should create" do
    mapper.wont_be_nil
  end

  it "should create no dependencies" do
    service = given_service(app1, [host1], empty_relationships)
    mapper.build_relationship_map(service).must_equal([])
  end

  it "should create single dependency" do
    given_host(host1, ip1, url)
    given_host(host2, ip2, url)
    service1 = given_service(app1, [host1], [app2])
    service2 = given_service(app2, [host2], empty_relationships)

    maps = mapper.build_relationship_map(service1)

    maps.count.must_equal(1)
    maps[0][:id].must_equal(app2)
    maps[0][:urls].must_include(url2)
  end

  it "should create single ELB dependency" do
    given_host(elb1, ip4, url4)
    service1 = given_service(app1, [host1], [elb1])
    services_provider.stubs(:get_by_id).with(elb1).returns(nil)
    maps = mapper.build_relationship_map(service1)

    maps.count.must_equal(1)
    maps[0][:id].must_equal(elb1)
    maps[0][:urls].must_include(url4)
  end

  it "should create multiple dependencies in a single element" do
    given_host(host1, ip1, url)
    given_host(host2, ip2, url)
    given_host(host3, ip3, url)
    service1 = given_service(app1, [host1], [app2])
    service2 = given_service(app2, [host2, host3], empty_relationships)

    maps = mapper.build_relationship_map(service1)

    maps.count.must_equal(1)
    maps[0][:id].must_equal(app2)
    maps[0][:urls].must_include(url2)
    maps[0][:urls].must_include(url3)
  end

  it "should create multiple dependencies in multiple elements" do
    given_host(host1, ip1, url)
    given_host(host2, ip2, url)
    given_host(host3, ip3, url)
    service1 = given_service(app1, [host1], [app2, app3])
    service2 = given_service(app2, [host2], [app3])
    service3 = given_service(app3, [host3], empty_relationships)

    maps = mapper.build_relationship_map(service1)
    maps.count.must_equal(2)
    maps.each do |map|
      [app2, app3].must_include(map[:id])
      if (map[:id == app2])
        map[:urls].must_include(url2)
      end
      if (map[:id == app3])
        map[:urls].must_include(url3)
      end
    end
  end

  it "should raise error when no service or relationship url can be built" do
    service1 = given_service(app1, [host1], [app2])
    services_provider.stubs(:get_by_id).with('app2').returns(nil)
    provision_provider.stubs(:get_by_id).with('app2').returns(nil)

    assert_raises RuntimeError do
      mapper.build_relationship_map(service1)
    end
  end

  it "should raise error when not able to build url from provisioned resource" do
    service1 = given_service(app1, [host1], [app2])
    services_provider.stubs(:get_by_id).with('app2').returns(service1)
    thehost1 = mock()
    thehost1.stubs(:get_id).returns(host1)
    thehost1.stubs(:get_ip).returns(nil)
    thehost1.stubs(:get_url).returns(nil)
    provision_provider.stubs(:get_by_id).with('host1').returns(thehost1)

    assert_raises RuntimeError do
      mapper.build_relationship_map(service1)
    end
  end

  def given_service(id, hosts, relationships)
    app_display_name = id
    service = Services::Definitions::Service.new(id, app_display_name, port, hosts, "/source_path", "/deploy", relationships, [])
    services_provider.stubs(:get_by_id).with(id).returns(service)
    return service
  end

  def given_host(id, ip, url)
    resource = Infrastructure::Definitions::ResourceData.new(id, "gws", 1)
    resource.get_params().add("ip", ip)
    resource.get_params().add("url", url)
    provisioned_resource = Provision::Definitions::ProvisionedResource.new(resource)
    provision_provider.stubs(:get_by_id).with(id).returns(provisioned_resource)
    return provisioned_resource
  end
end