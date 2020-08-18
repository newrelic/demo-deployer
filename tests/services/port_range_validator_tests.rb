require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validation_error"

require "./src/services/port_range_validator"

describe "Service::PortRangeValidator" do
  let(:services) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:available_ranges) { [] }
  let(:validator) { Services::PortRangeValidator.new(available_ranges, error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end
    
  it "should now allow any port when no ranges" do
    given_port(1234)
    validator.execute(services).must_include(error_message)
  end
    
  it "should allow positive port number" do
    given_available_port_range(1000, 2000)
    given_port(1234)
    validator.execute(services).must_be_nil()
  end

  it "should not allow negative number" do
    given_available_port_range(1000, 2000)
    given_port(-80)
    validator.execute(services).must_include(error_message)
  end
  
  it "should not allow 0" do
    given_available_port_range(1000, 2000)
    given_port(0)
    validator.execute(services).must_include(error_message)
  end
  
  it "should allow multiple services port number" do
    given_available_port_range(80, 80)
    given_available_port_range(1024, 65535)
    given_port(80)
    given_port(8080)
    validator.execute(services).must_be_nil()
  end
  
  it "should NOT allow before begining of port range" do
    given_available_port_range(1024, 65535)
    given_port(1023)
    validator.execute(services).must_include(error_message)
  end

  it "should NOT after ending of port range" do
    given_available_port_range(1024, 65535)
    given_port(65536)
    validator.execute(services).must_include(error_message)
  end

  it "should allow begining of port range" do
    given_available_port_range(1024, 65535)
    given_port(1024)
    validator.execute(services).must_be_nil()
  end
  
  it "should allow ending of port range" do
    given_available_port_range(1024, 65535)
    given_port(65535)
    validator.execute(services).must_be_nil()
  end
  
  it "should ignore services with invalid number for port" do
    given_available_port_range(1024, 65535)
    given_port("abcd")
    validator.execute(services).must_be_nil()
  end

  it "should services with no port" do
    given_available_port_range(1024, 65535)
    given_no_port()
    validator.execute(services).must_be_nil()
  end

  it "should throw when a range is not defined correctly" do
    available_ranges.push([80])
    given_port(80)
    error = assert_raises Common::ValidationError do
      validator.execute(services)
    end        
    error.message.must_include("Invalid port range defined")    
  end
  
  def given_available_port_range(from, to)
    available_ranges.push([from, to])
  end

  def given_no_port()
    services.push({})
  end

  def given_port(port)
    services.push({"port"=> port})
  end

end