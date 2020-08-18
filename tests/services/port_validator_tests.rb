require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/services/port_validator"

describe "Service::PortValidator" do
  let(:services) { [] }
  let(:port_type_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:port_range_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:port_destination_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:validator) { Services::PortValidator.new(port_type_validator, port_range_validator, port_destination_validator) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate port type" do
    port_type_validator.expects(:execute)
    validator.execute(services)
  end
  
  it "should validate port is a defined number" do
    port_range_validator.expects(:execute)
    validator.execute(services)
  end

  it "should validate port and destination do not overlap" do
    port_destination_validator.expects(:execute)
    validator.execute(services)
  end

end