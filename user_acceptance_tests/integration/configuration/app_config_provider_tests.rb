require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/validation_error"
require "./src/configuration_orchestrator"
require "./src/context"
require "./user_acceptance_tests/spoofers/deployment_directory_spoofer"
require "./user_acceptance_tests/spoofers/test_spoofers"

describe "UserAcceptanceTests::AppConfig::Provider" do
  let(:command_line_arguments) { [] }
  let(:context) { Context.new() }
  let(:orchestrator) { ConfigurationOrchestrator.new(context) }
  let(:app_config_provider) { context.get_app_config_provider() }
  let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new([])}

  after do
    spoofer = UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new("user.uat.json", "deploy.uat.json")
    app_config_provider = context.get_app_config_provider()
    if (app_config_provider != nil)
      path = context.get_app_config_provider().get_execution_path()
      spoofer.set_directory_path(path)
    end
    spoofers.add(spoofer)
    spoofers.dispose()
  end

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  before do
    given_template_config_files()
    orchestrator.execute(command_line_arguments)
  end

  it "should get execution path" do
    app_config_provider.get_execution_path().wont_be_nil
    app_config_provider.get_execution_path().wont_be_empty
  end

  it "should get summary filename" do
    app_config_provider.get_summary_filename().wont_be_nil
    app_config_provider.get_summary_filename().wont_be_empty
  end

  it "should get service id length" do
    app_config_provider.get_service_id_max_length().wont_be_nil
  end

  it "should get resource id length" do
    app_config_provider.get_resource_id_max_length().wont_be_nil    
  end

  it "should get_aws_elb_port" do
    app_config_provider.get_aws_elb_port().wont_be_nil
  end

  it "should get_aws_ec2_supported_sizes" do
    app_config_provider.get_aws_ec2_supported_sizes().wont_be_nil
    app_config_provider.get_aws_ec2_supported_sizes().wont_be_empty
  end

  it "should get_aws_elb_max_listeners" do
    app_config_provider.get_aws_elb_max_listeners().wont_be_nil
  end

  private
  def given_template_config_files()
    command_line_arguments.push("-c")
    command_line_arguments.push("user_acceptance_tests/user.uat.json")
    command_line_arguments.push("-d")
    command_line_arguments.push("#{__dir__}/deploy.uat.json")
    command_line_arguments.push("-l")
    command_line_arguments.push("error")
    spoofers.add(UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new("user.uat.json", "deploy.uat.json"))
  end

end