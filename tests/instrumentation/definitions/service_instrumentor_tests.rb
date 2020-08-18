require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/instrumentation/definitions/service_instrumentor"

describe "Instrumentation::Definitions::ServiceInstrumentor" do

  let(:id) { "id" }
  let(:service_id) { "service_id" }
  let(:provider) { "provider" }
  let(:version) { "1.2.3" }
  let(:deploy_script_path) { "linux" }
  let(:source_path) { "local" }
  let(:service) { m = mock(); m.stubs(:get_id).returns(service_id); m }

  it "should create service instrumentor" do
    instrumentor = Instrumentation::Definitions::ServiceInstrumentor.new(id, service, provider, version, deploy_script_path, source_path)
    instrumentor.to_s().must_include("ServiceInstrumentor")
    instrumentor.get_id().must_equal(id)
    instrumentor.get_item_id().must_equal(service_id)
    instrumentor.get_provider().must_equal(provider)
    instrumentor.get_version().must_equal(version)
    instrumentor.get_deploy_script_path().must_equal(deploy_script_path)
    instrumentor.get_source_path().must_equal(source_path)
  end

end