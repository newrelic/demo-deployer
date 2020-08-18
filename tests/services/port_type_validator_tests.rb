require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/services/port_type_validator"

describe "Service::PortTypeValidator" do
  let(:services) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:validator) { Services::PortTypeValidator.new(error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end
    
  it "should allow positive port number" do
    given_port(1234)
    validator.execute(services).must_be_nil()
  end
  
  it "should allow any number" do
    given_port(-80)
    validator.execute(services).must_be_nil()
  end
  
  it "should allow 0" do
    given_port(0)
    validator.execute(services).must_be_nil()
  end
  
  it "should allow multiple services port number" do
    given_port(1234)
    given_port(567)
    given_port(80)
    given_port(220)
    validator.execute(services).must_be_nil()
  end

  it "should not allow services with invalid number for port" do
    given_port("abcd")
    validator.execute(services).must_include(error_message)
    validator.execute(services)
  end

  it "should not allow any services with invalid number for port" do
    given_port("abcd")
    given_port("host1")
    given_port("undefined")
    output = validator.execute(services)
    output.must_include("abcd")
    output.must_include("host1")
    output.must_include("undefined")
  end

  it "should not report service with missing port" do
    given_no_port()
    validator.execute(services).must_be_nil()
  end
  
  def given_no_port()
    services.push({})
  end

  def given_port(port)
    services.push({"port"=> port})
  end

end