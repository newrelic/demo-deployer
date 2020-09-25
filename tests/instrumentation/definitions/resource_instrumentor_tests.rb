require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/instrumentation/definitions/resource_instrumentor"

describe "Instrumentation::Definitions::ResourceInstrumentor" do

  let(:id) { "id" }
  let(:resource_id) { "resource_id" }
  let(:provider) { "provider" }
  let(:version) { "1.2.3" }
  let(:deploy_script_path) { "linux" }
  let(:source_path) { "local" }
  let(:resource) { m = mock(); m.stubs(:get_id).returns(resource_id); m }

  it "should create resource instrumentor" do
    instrumentor = Instrumentation::Definitions::ResourceInstrumentor.new(id, provider, version, deploy_script_path, source_path)
    instrumentor.set_item(resource)
    instrumentor.to_s().must_include("ResourceInstrumentor")
    instrumentor.get_id().must_equal(id)
    instrumentor.get_item_id().must_equal(resource_id)
    instrumentor.get_provider().must_equal(provider)
    instrumentor.get_version().must_equal(version)
    instrumentor.get_deploy_script_path().must_equal(deploy_script_path)
    instrumentor.get_source_path().must_equal(source_path)
  end

end