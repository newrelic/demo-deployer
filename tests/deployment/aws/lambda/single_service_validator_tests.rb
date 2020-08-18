require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/definitions/service"
require "./src/infrastructure/definitions/resource_data"
require "./src/deployment/aws/lambda/single_service_validator"

describe "Deployment::Aws::Lambda::SingleServiceValidator" do
  let(:resources) { [] }
  let(:services) { [] }
  let(:error_message) { "There was an error while validating:"}
  let(:validator) { Deployment::Aws::Lambda::SingleServiceValidator.new(services, error_message) }
  
  it "should create validator" do
    validator.wont_be_nil
  end

  it "should allow when no service" do
    given_lambda_resource("server1")
    validator.execute(resources).must_be_nil()
  end

  it "should allow when one service" do
    given_lambda_resource("server1")
    given_service("app1", ["server1"])
    validator.execute(resources).must_be_nil()
  end

  it "should allow when one service multiple same destinations" do
    given_lambda_resource("server1")
    given_service("app1", ["server1", "server1", "server1"])
    validator.execute(resources).must_be_nil()
  end

  it "should NOT allow when two service" do
    given_lambda_resource("server1")
    given_service("app1", ["server1"])
    given_service("app2", ["server1"])
    result = validator.execute(resources)
    result.wont_be_nil()
    result.must_include("app1")
    result.must_include("app2")
    result.must_include("server1")
  end

  it "should allow when two services on distinct resources" do
    given_lambda_resource("server1")
    given_lambda_resource("server2")
    given_service("app1", ["server1"])
    given_service("app2", ["server2"])
    validator.execute(resources).must_be_nil()
  end

  it "should allow when one service on distinct resources" do
    given_lambda_resource("server1")
    given_lambda_resource("server2")
    given_service("app1", ["server1","server2"])
    validator.execute(resources).must_be_nil()
  end

  def given_lambda_resource(id)
    resources.push(Infrastructure::Definitions::ResourceData.new(id, "any", 0))
  end
  
  def given_service(id, destinations)
    display_name = id
    services.push(Services::Definitions::Service.new(id, display_name, 80, destinations || [], "/source_path", "/deploy", [], []))
  end

end
