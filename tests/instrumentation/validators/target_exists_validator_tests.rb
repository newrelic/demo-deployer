require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"
require "./src/instrumentation/validators/target_exists_validator"
require "./src/instrumentation/definitions/instrumentor"

describe "Instrumentation::TargetExistsValidatorTests" do
  let(:instrumentors) { [] }
  let(:ids) { [] }
  let(:key) { "serviceIds" }
  let(:error_msg) { "error msg " }
  let(:validator) { Instrumentation::Validators::TargetExistsValidator.new(key, error_msg) }

  it "Should not error when no instrumentors" do
    validator.execute(instrumentors, ids).must_be_nil()
  end

  it "Should not error when empty ids array" do
    given_instrumentor([])
    validator.execute(instrumentors, ids).must_be_nil()
  end

  it "Should not error when nil ids array" do
    given_instrumentor()
    validator.execute(instrumentors, ids).must_be_nil()
  end

  it "Should not error with valid ids" do
    given_instrumentor(["host1"])
    given_id("host1")
    validator.execute(instrumentors, ids).must_be_nil()
  end

  it "Should error with missing resource reference" do
    given_instrumentor(["host2"])
    given_id("host1")
    validator.execute(instrumentors, ids)
  end

  it "Should error with multiple missing resource references" do
    given_instrumentor(["host2"])
    given_instrumentor(["host3"])
    given_id("host1")
    error = validator.execute(instrumentors, ids)
    error.wont_include("host1")
    error.must_include("host2")
    error.must_include("host3")
  end

  it "Should not error with uppercased ids" do
    given_instrumentor(["HOST1"])
    given_instrumentor(["Host2"])
    given_id("host1")
    given_id("host2")
    error = validator.execute(instrumentors, ids)
    error.wont_include("host1")
    error.wont_include("host2")
  end

  it "Should not error with valid resource reference and extra existing resources" do
    given_instrumentor(["host1"])
    given_id("host2")
    given_id("host1")
    validator.execute(instrumentors, ids).must_be_nil()
  end

  def given_instrumentor(ids = nil)
    instrumentor = {}
    instrumentor["serviceIds"] = ids
    instrumentors.push(JSON.parse(instrumentor.to_json()))
  end

  def given_id(id = nil)
    ids.push(id)
  end

end