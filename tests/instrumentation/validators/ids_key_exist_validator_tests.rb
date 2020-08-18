require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"
require "./src/instrumentation/validators/ids_key_exist_validator"

describe "Instrumentation::Validators::IdsKeyExistValidator" do
  let(:instrumentors) { [] }
  let(:required_keys) { ["serviceIds", "resourceIds"] }
  let(:validator) { nil }
  let(:key_value) { [] }

  it "should create validator" do
    get_validator().wont_be_nil()
  end

  it "should not error when ids key exists" do
    given_instrumentor("serviceIds", ["host1"])
    validator_execute(instrumentors).must_be_nil
  end

  it "should error when instrumentor does not include an ids key" do
    given_instrumentor("notKey")
    validator_execute(instrumentors).must_include("missing")
    validator_execute(instrumentors).must_include("1")
  end

  it "should error when multiple instrumentors don't include an ids key" do
    given_instrumentor("notKey")
    given_instrumentor("notKeyAGain")
    validator_execute(instrumentors).must_include("missing")
    validator_execute(instrumentors).must_include("2")
  end

  def given_instrumentor(key = nil, key_value = nil, provider = nil, deploy_script_path = nil, version = nil)
    instrumentor = {}
    instrumentor[key] = key_value
    instrumentors.push(JSON.parse(instrumentor.to_json()))
  end

  def validator_execute(instrumentors)
    return get_validator().execute(instrumentors)
  end

  def get_validator()
    return Instrumentation::Validators::IdsKeyExistValidator.new(required_keys)
  end

end