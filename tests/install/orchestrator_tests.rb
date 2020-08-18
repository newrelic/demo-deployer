require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/install/orchestrator"
require "./tests/context_builder"
require "./src/common/logger/logger"

describe "Install::Orchestrator" do

  let(:context){ Tests::ContextBuilder.new().build() }
  let(:install_orchestrator) { m = mock(); m.stubs(:execute); m }
  let(:install_provider) { m = mock(); m}
  let(:packager) { m = mock(); m.stubs(:execute); m}  
  let(:builder) { m = mock(); m.stubs(:build).returns([]); m.stubs(:with_onhost_instrumentations).returns(); m}
  let(:log_token) { m = mock(); m.stubs(:success).returns(nil); m.stubs(:error).returns(nil);  m }
  let(:install_definition_builder) {  m = mock(); m.stubs(:build).returns([]); m  }
  let(:deployment_name) { "deployname" }
  let(:orchestrator) { Install::Orchestrator.new(context, install_provider, packager, install_orchestrator) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  it "execute should return provision provider" do
    given_builder()
    orchestrator.execute()
  end

  it "should execute packager" do
    given_builder()
    packager.expects(:execute)
    orchestrator.execute()
  end

  def given_builder()
    orchestrator.stubs(:get_install_definitions_builder).returns(install_definition_builder)
    install_definition_builder.stubs(:with_onhost_instrumentations).returns(install_definition_builder)
    install_definition_builder.stubs(:with_services).returns(install_definition_builder)
    install_definition_builder.stubs(:with_service_instrumentations).returns(install_definition_builder)
  end


end
