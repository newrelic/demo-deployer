require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"

require "./src/instrumentation/provider"
require "./src/services/definitions/service"
require "./src/infrastructure/definitions/resource_data"

describe "Instrumentation::Provider" do

  let(:context){ Tests::ContextBuilder.new().build() }
  let(:empty_json) { {} }
  let(:services) { [] }
  let(:resources) { [] }
  let(:git_proxy) { m = mock(); m.stubs(:clone); m }

  it "should not create any instrumentors when empty" do
    provider = given_provider(empty_json)
    provider.get_all_resource_instrumentors().length().must_equal(0)
  end

  it "should create single resource instrumentor" do
    given_resource("host1")
    provider = given_provider(JSON.parse(
        {
          "resources": [
            {
              "id": "infra",
              "resource_ids": ["host1"]
            }
          ]
        }
      .to_json()))
    provider.get_all_resource_instrumentors().length().must_equal(1)
    provider.get_all_resource_instrumentors()[0].get_id().must_equal("infra")
    provider.get_all_resource_instrumentors()[0].get_item_id().must_equal("host1")
  end

  it "should create 2 resource instrumentors" do
    given_resource("host1")
    given_resource("host2")
    provider = given_provider(JSON.parse(
        {
          "resources": [
            {
              "id": "infra",
              "resource_ids": ["host1", "host2"]
            }
          ]
        }
      .to_json()))
    provider.get_all_resource_instrumentors().length().must_equal(2)
  end

  it "should create multiple resource instrumentors" do
    given_resource("host1")
    given_resource("host2")
    given_resource("host3")
    given_resource("host4")
    provider = given_provider(JSON.parse(
        {
          "resources": [
            {
              "id": "infra",
              "resource_ids": ["host1", "host2"]
            },
            {
              "id": "another",
              "resource_ids": ["host3", "host4"]
            }
          ]
        }
      .to_json()))
    provider.get_all_resource_instrumentors().length().must_equal(4)
  end

  it "should create single service instrumentor" do
    given_service("app1", ["host1", "host2"], 80)
    provider = given_provider(JSON.parse(
        {
          "services": [
            {
              "id": "agent",
              "service_ids": ["app1"]
            }
          ]
        }
      .to_json()))
    provider.get_all_service_instrumentors().length().must_equal(1)
    provider.get_all_service_instrumentors()[0].get_id().must_equal("agent")
    provider.get_all_service_instrumentors()[0].get_item_id().must_equal("app1")
  end

  it "should create 2 service instrumentors" do
    given_service("app1", ["host1", "host2"], 80)
    given_service("app2", ["host1", "host2"], 80)
    provider = given_provider(JSON.parse(
        {
          "services": [
            {
              "id": "agent",
              "service_ids": ["app1", "app2"]
            }
          ]
        }
      .to_json()))
    provider.get_all_service_instrumentors().length().must_equal(2)
  end
  
  it "should create multiple service instrumentors" do
    given_service("app1", ["host1","host2"], 80)
    given_service("app2", ["host1","host2"], 80)
    given_service("app3", ["host3","host4"], 80)
    given_service("app4", ["host3","host4"], 80)
    provider = given_provider(JSON.parse(
        {
          "services": [
            {
              "id": "agent",
              "service_ids": ["app1", "app2"]
            },
            {
              "id": "another",
              "service_ids": ["app3", "app4"]
            }
          ]
        }
      .to_json()))
    provider.get_all_service_instrumentors().length().must_equal(4)
  end

  it "should create global instrumentor" do
     provider = given_provider(JSON.parse(
        {
          "global": [
            {
              "id": "global-agent"
            }
          ]
        }
      .to_json()))
    provider.get_all_global_instrumentors().length().must_equal(1)
  end

  it "should create multiple global instrumentors" do 
    provider = given_provider(JSON.parse(
        {
          "global": [
            {
              "id": "global-agent-1"
            },
            {
              "id": "global-agent-2"
            }
          ]
        }
      .to_json()))
    provider.get_all_global_instrumentors().length().must_equal(2)
  end

  it "should not create any intrumentors" do
    provider = given_provider(JSON.parse({}.to_json()))
    provider.get_all().length().must_equal(0)
  end

  def given_provider(json)
    return Instrumentation::Provider.new(context, json, "/tmp", resources, services, git_proxy)
  end

  def given_resource(id)
    resources.push(Infrastructure::Definitions::ResourceData.new(id, "any", 0))
  end
  
  def given_service(id, destinations, port)
    display_name = id
    services.push(Services::Definitions::Service.new(id, display_name, port, destinations || [], "/source_path", "/deploy", [], []))
  end
end