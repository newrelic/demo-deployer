require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/instrumentor_item_exist_validator"

describe "Deployment::InstrumentorItemExistValidator" do
  let(:instrumentors) { [] }
  let(:error_message) {"There is an instrumentation validation error"}
  let(:validator) { Deployment::InstrumentorItemExistValidator.new(error_message) }

  it "should NOT error when no instrumentors defined" do
    validator.execute(instrumentors).must_be_nil()
  end

  it "should NOT error when item_id present" do
    given_instrumentor("item1")
    validator.execute(instrumentors).must_be_nil()
  end

  it "should error when no item_id" do
    given_instrumentor(nil)
    validator.execute(instrumentors).wont_be_nil()
  end

  def given_instrumentor(item_id)
    instrumentor = mock()
    instrumentor.stubs(:get_item_id).returns(item_id)
    instrumentors.push(instrumentor)
  end


end