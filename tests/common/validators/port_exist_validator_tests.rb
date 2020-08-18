require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/definitions/service"
require "./src/infrastructure/definitions/resource_data"
require "./src/common/validators/port_exist_validator"

describe "Commono::Validators::PortExistValidator" do
  let(:resources) { [] }
  let(:services) { [] }
  let(:error_message) { "There was an error while validating:"}
  let(:validator) { Common::Validators::PortExistValidator.new(services, error_message) }
  
  it "should create validator" do
    validator.wont_be_nil
  end

  it "should allow when no service" do
    given_resource("server1")
    validator.execute(resources).must_be_nil()
  end

  it "should allow when one service" do
    given_resource("server1")
    given_service("app1", ["server1"], 80)
    validator.execute(resources).must_be_nil()
  end

  it "should allow when one service multiple same destinations" do
    given_resource("server1")
    given_service("app1", ["server1", "server1", "server1"], 80)
    validator.execute(resources).must_be_nil()
  end

  it "should allow when two services on distinct resources" do
    given_resource("server1")
    given_resource("server2")
    given_service("app1", ["server1"], 80)
    given_service("app2", ["server2"], 80)
    validator.execute(resources).must_be_nil()
  end

  def given_resource(id)
    resources.push(Infrastructure::Definitions::ResourceData.new(id, "any", 0))
  end
  
  def given_service(id, destinations, port)
    display_name = id
    services.push(Services::Definitions::Service.new(id, display_name, port, destinations || [], "/source_path", "/deploy", [], []))
  end

end
