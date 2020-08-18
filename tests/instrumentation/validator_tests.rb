require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/instrumentation/validator"
require "./tests/context_builder"

describe "Instrumentation::Validator::execute" do
  let(:instrumentors) { {} }
  let(:resource_ids) { [] }
  let(:service_ids) { [] }
  let(:id_validator) { m = mock(); m.stubs(:execute); m }
  let(:resource_ids_validator) { m = mock(); m.stubs(:execute); m }
  let(:service_ids_validator) { m = mock(); m.stubs(:execute); m }
  let(:credential_block_exists_validator) { m = mock(); m.stubs(:execute); m }
  let(:source_location_validator) { m = mock(); m.stubs(:execute); m }
  let(:only_one_source_location_validator) { m = mock(); m.stubs(:execute); m }
  let(:deploy_script_path_validator) { m = mock(); m.stubs(:execute); m }
  let(:resource_validators) { m = mock(); m.stubs(:execute); m }
  let(:service_validators) { m = mock(); m.stubs(:execute); m }
  let(:unique_id_validator) { m = mock(); m.stubs(:execute); m }  
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:validator) { Instrumentation::Validator.new(context,
    id_validator,
    resource_ids_validator,
    service_ids_validator,
    credential_block_exists_validator,
    source_location_validator,
    only_one_source_location_validator,
    deploy_script_path_validator,
    resource_validators,
    service_validators,
    unique_id_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate id exists" do
    id_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end
  
  it "should validate credential block exists" do
    credential_block_exists_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  it "should validate source location defined" do
    source_location_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  it "should validate only one source location defined" do
    only_one_source_location_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  it "should validate resource validator execute" do
    resource_ids_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  it "should validate service validator execute" do
    service_ids_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  it "should validate resources ids" do
    given_resource("host1")
    given_resource_instrumentor("nragent", ["host1"])
    resource_validators.expects(:execute).with(["host1"], ["host1"])
    validator.execute(instrumentors, resource_ids, service_ids)
  end
  
  it "should validate service ids" do
    given_service("app1")
    given_service_instrumentor("nragent", ["app1"])
    service_validators.expects(:execute).with(["app1"], ["app1"])
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  it "should validate unique id validator execute" do
    unique_id_validator.expects(:execute)
    validator.execute(instrumentors, resource_ids, service_ids)
  end

  def given_resource(id)
    resource_ids.push(id)
  end

  def given_resource_instrumentor(id, resource_ids)
    resources = instrumentors["resources"] || []
    definition = {}
    definition["id"] = id
    definition["resource_ids"] = resource_ids
    resources.push(definition)
    instrumentors["resources"] = resources
  end
  
  def given_service(id)
    service_ids.push(id)
  end

  def given_service_instrumentor(id, service_ids)
    services = instrumentors["services"] || []
    definition = {}
    definition["id"] = id
    definition["service_ids"] = service_ids
    services.push(definition)
    instrumentors["services"] = services
  end
end