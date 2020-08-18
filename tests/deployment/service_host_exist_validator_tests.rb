require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/validator"
require "./src/services/definitions/service"

describe "Deployment::ServiceHostExistValidator" do
  let(:services) { [] }
  let(:resource_ids) { [] }
  let(:validator) { Deployment::ServiceHostExistValidator.new() }

  it "Should NOT error when no services" do
    validator.execute(services, resource_ids).must_be_nil()
  end

  it "Should NOT error when no destination" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, [], "path/to/source", "/deploy", [], []))
    validator.execute(services, resource_ids).must_be_nil()
  end

  it "Should NOT error when service has a defined host destination" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2"], "path/to/source", "/deploy", [], []))
    resource_ids.push("myec2")
    validator.execute(services, resource_ids).must_be_nil()
  end

  it "Should error when a service has missing host destination" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2"], "path/to/source", "/deploy", [], []))
    validator.execute(services, resource_ids).wont_be_nil()
  end

  it "Should error when a service has miss-matching host destination" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2"], "path/to/source", "/deploy", [], []))
    resource_ids.push("appenginehost")
    validator.execute(services, resource_ids).wont_be_nil()
  end

  it "Should error when multiple services have missing host destinations" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2"], "path/to/source", "/deploy", [], []))
    services.push(Services::Definitions::Service.new("simultron", "Simultron", 80, ["anotherec2"], "path/to/source", "/deploy", [], []))

    error = validator.execute(services, resource_ids)

    error.wont_be_nil()
    error.must_include("apptron.myec2")
    error.must_include("simultron.anotherec2")
  end

  it "Should error when one of multiple services have missing host destinations" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2"], "path/to/source", "/deploy", [], []))
    services.push(Services::Definitions::Service.new("simultron", "Simultron", 80, ["anotherec2"], "path/to/source", "/deploy", [], []))
    resource_ids.push("anotherec2")
    validator.execute(services, resource_ids).must_include("apptron.myec2")
  end

  it "Should NOT error for services having a matching host/destination when another service has a missing destination" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2"], "path/to/source", "/deploy", [], []))
    services.push(Services::Definitions::Service.new("simultron", "Simultron", 80, ["anotherec2"], "path/to/source", "/deploy", [], []))
    resource_ids.push("anotherec2")
    validator.execute(services, resource_ids).wont_include("simultron")
  end

  it "Should error when a service has one of many host destinations missing" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2", "anotherec2", "anEc3"], "path/to/source", "/deploy", [], []))
    resource_ids.push("myec2", "anEc3")
    validator.execute(services, resource_ids).must_include("apptron.anotherec2")
  end

  it "Should NOT report service destinations that are matching when one destination is NOT matching" do
    services.push(Services::Definitions::Service.new("apptron", "Apptron", 80, ["myec2", "anotherec2", "anEc3"], "path/to/source", "/deploy", [], []))
    resource_ids.push("myec2", "anEc3")
    validator.execute(services, resource_ids).wont_include("myec2")
  end
end