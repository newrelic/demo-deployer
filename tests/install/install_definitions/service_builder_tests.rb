require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/install/install_definitions/service_builder"
require "./tests/context_builder"

describe "Install::InstallDefinitions::ServiceBuilder" do

  let(:context_builder){ Tests::ContextBuilder.new() }

  it "should build for single service" do
    given_ec2_resource("apphost")
    given_service("app1", ["apphost"])
    given_provisioned_service("apphost", "1.2.3.4")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    definitions[0].get_roles_path().must_include("deploy")
    definitions[0].get_erb_input_path().must_equal("src/common/install/templates")
    definitions[0].get_yaml_output_path.must_equal("#{get_deployment_name()}/app1/apphost")
  end

  it "should build roles path with local" do
    given_app_config("ansibleRolesPath", "/tmp")
    given_ec2_resource("apphost")
    given_service("app1", ["apphost"])
    given_provisioned_service("apphost", "1.2.3.4")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    definitions[0].get_roles_path().must_equal("/deploy:/tmp")
  end

  it "should have action vars" do
    given_ec2_resource("apphost")
    given_service("app1", ["apphost"])
    given_provisioned_service("apphost", "1.2.3.4")
    definitions = given_builder().build_install_definitions()
    definitions.length.must_equal(1)
    vars = definitions[0].get_action_vars()
    vars["service_id"].must_equal("app1")
    vars["deployment_name"].must_equal(get_deployment_name())
    vars["service_deployment_name"].must_equal("#{get_deployment_name()}_app1")
  end

  def given_app_config(key, value)
    context_builder.app_config().with(key, value)
  end

  def given_service(service_id, destinations, port = 5000)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations)
  end

  def given_ec2_resource(id)
    context_builder.infrastructure().ec2(id)
  end  

  def given_provisioned_service(id, ip)
    context_builder.provision().service_host(id, ip)
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
    return Install::InstallDefinitions::ServiceBuilder.new(@context, provisioned_resources)
  end

end
