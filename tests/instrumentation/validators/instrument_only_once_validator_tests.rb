require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"
require "./src/instrumentation/validators/instrument_only_once_validator"

describe "Instrumentation::Validators::InstrumentOnlyOnceValidator" do
  let(:instrumentors) { [] }
  let(:ids) { [] }
  let(:key_name) { "myIds" }
  let(:validator) { Instrumentation::Validators::InstrumentOnlyOnceValidator.new(key_name) }

  it "Should not be nil" do
    validator.wont_be_nil()
  end

  it "Should not error when no resources and instrumentors" do
    validator.execute(instrumentors, ids).must_be_nil()
  end

  it "Should not error when nil instrumentor array" do
    given_instrumentor(nil)
    validator.execute(instrumentors, ids).must_be_nil()
  end

  it "Should error with duplicate id references" do
    given_instrumentor(["host1", "host2"], "1.2.3")
    given_instrumentor(["host2", "host3"], "4.5.6")
    given_id("host1")
    given_id("host2")
    given_id("host3")
    validator.execute(instrumentors, ids).must_include("host2")
  end

  it "Should not error if instrumented id plus uninstrumented id" do
    given_instrumentor(["host1"])
    given_id("host2")
    given_id("host1")
    validator.execute(instrumentors, ids).must_be_nil()
  end

  def given_instrumentor(ids, version = nil)
    instrumentor = {}
    instrumentor["myIds"] = ids
    instrumentor["version"] = version
    instrumentors.push(JSON.parse(instrumentor.to_json()))
  end

  def given_id(id = nil)
    ids.push(id)
  end

end