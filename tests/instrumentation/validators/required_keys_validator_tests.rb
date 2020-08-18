require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"
require "./src/instrumentation/validators/required_keys_validator"

describe "Instrumentation::Validators::RequiredKeysValidator" do
  let(:instrumentors) { [] }
  let(:required_keys) { [] }
  let(:resource_ids) { ["host1", "host2"] }

  it "should create validator" do
    get_validator().wont_be_nil()
  end

  it "should not error when nothing is required" do
    validator_execute(instrumentors).must_be_nil()
  end

  it "should not error when required field exists" do
    required_keys.push("resourceIds")
    given_instrumentor(resource_ids)
    validator = validator_execute(instrumentors)
    validator.must_be_nil
  end

  it "should error when required_keys not found" do
    required_keys.push("popscicles")
    given_instrumentor(resource_ids)
    validator = validator_execute(instrumentors)
    validator.must_include("popscicles")
  end

  it "should fail with two missing required fields" do
    required_keys.push("resourceIds", "provider", "deploy_script_path")
    given_instrumentor(["host1"])
    validator = validator_execute(instrumentors)
    validator.must_include("provider")
    validator.must_include("deploy_script_path")
  end

  def given_instrumentor(resource_ids = nil, provider = nil, deploy_script_path = nil, version = nil)
    instrumentor = {}
    instrumentor["resourceIds"] = resource_ids
    instrumentor["provider"] = provider
    instrumentor["deploy_script_path"] = deploy_script_path
    instrumentor["version"] = version
    instrumentors.push(JSON.parse(instrumentor.to_json()))
  end

  def validator_execute(instrumentors)
    return get_validator().execute(instrumentors)
  end

  def get_validator()
    return Instrumentation::Validators::RequiredKeysValidator.new(required_keys)
  end

end