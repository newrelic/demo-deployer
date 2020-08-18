require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require './src/install/install_definitions/on_host_instrumentation_builder'
require "./tests/context_builder"

describe "Install::InstallDefinitions::OnHostInstrumentationBuilder" do

  let(:agent_version) { "1.0" }
  let(:context_builder){ Tests::ContextBuilder.new() }

  it "should build for single instrumented service" do
    given_ec2_resource("apphost")
    given_provisioned_resource("apphost", "1.2.3.4")
    given_instrumentor("instrument1", "apphost")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    definitions[0].get_erb_input_path().must_equal("src/common/install/templates")
    definitions[0].get_yaml_output_path.must_equal("#{get_deployment_name()}/apphost/instrument1")
  end

  it "should build roles path with local" do
    given_app_config("ansibleRolesPath", "/tmp")
    given_ec2_resource("apphost")
    given_provisioned_resource("apphost", "1.2.3.4")
    given_instrumentor("instrument1", "apphost")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    definitions[0].get_roles_path().must_equal("src/path/deploy:/tmp")
  end

  it "should have action vars" do
    given_ec2_resource("apphost")
    given_provisioned_resource("apphost", "1.2.3.4")
    given_instrumentor("instrument1", "apphost")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    vars = definitions[0].get_action_vars()
    vars["resource_id"].must_equal("apphost")
    vars["version"].must_equal(agent_version)
    vars["deployment_name"].must_equal(get_deployment_name())
    vars["resource_deployment_name"].must_equal("#{get_deployment_name()}_apphost")    
  end

  it "should have params in action vars" do
    given_ec2_resource("apphost")
    given_provisioned_resource("apphost", "1.2.3.4")
    given_instrumentor("instrument1", "apphost", {"fruit"=>"apple", "code"=>"blue"})
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    vars = definitions[0].get_action_vars()
    vars["resource_id"].must_equal("apphost")
    vars["fruit"].must_equal("apple")
    vars["code"].must_equal("blue")
  end

  it "should NOT build when no instrumentor" do
    given_ec2_resource("apphost")
    given_provisioned_resource("apphost", "1.2.3.4")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(0)
  end

  def given_app_config(key, value)
    context_builder.app_config().with(key, value)
  end

  def given_ec2_resource(id)
    context_builder.infrastructure().ec2(id)
  end  

  def given_provisioned_resource(id, ip)
    context_builder.provision().service_host(id, ip)
  end

  def given_instrumentor(id, resource_id, params = nil)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    provider = "newrelic"
    context_builder.instrumentations().resource(id, resource_id, provider, local_source_path, deploy_script_path, agent_version, params)
  end

  def given_builder()
    return @builder ||= create_builder()
  end

  def get_deployment_name()
    return @deployment_name ||= @context.get_command_line_provider().get_deployment_name()
  end

  def create_builder()
    @context = context_builder.build()
    provisioned_resources = @context.get_provision_provider().get_all()
    return Install::InstallDefinitions::OnHostInstrumentationBuilder.new(@context, provisioned_resources)
  end

end
