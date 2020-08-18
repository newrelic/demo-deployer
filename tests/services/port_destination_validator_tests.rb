require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/port_destination_validator"

describe "Service::PortDestinationValidator" do
  let(:services) { [] }
  let(:error_message) { "there was a significant error while running a test" }
  let(:validator) { Services::PortDestinationValidator.new(error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end    

  it "should allow single service" do
    given_service(80, "hostname")
    validator.execute(services).must_be_nil()
  end

  it "should allow service same port different host" do
    given_service(80, "host1")
    given_service(80, "host2")
    validator.execute(services).must_be_nil()
  end
  
  it "should allow service same host different port" do
    given_service(80, "hostname")
    given_service(220, "hostname")
    validator.execute(services).must_be_nil()
  end

  it "should not allow service same port and host" do
    given_service(80, "hostname")
    given_service(80, "hostname")
    validator.execute(services).wont_be_nil()
  end

  it "should output service ids that overlap" do
    given_service("app1", 80, "hostname")
    given_service("app2", 80, "hostname")
    output = validator.execute(services)
    output.must_include("app1", "app2")

  end

  def given_service(id = nil, port, destination)
    service = {}
    service['id'] = id
    service["port"] = port
    service["destinations"] = [destination]
    services.push(service)
  end

end