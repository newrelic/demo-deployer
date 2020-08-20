require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/validation_error"

require "./src/configuration_orchestrator"
require "./src/context"
require "./user_acceptance_tests/spoofers/deployment_directory_spoofer"
require "./user_acceptance_tests/spoofers/test_spoofers"
require "./user_acceptance_tests/file_finder"

describe "UserAcceptanceTests::ContextProvider" do
  let(:command_line_arguments) { [] }
  let(:user_config_filename) { "uatuser.json" }
  let(:context) { Context.new() }
  let(:orchestrator) { ConfigurationOrchestrator.new(context) }
  let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new([])}

  after do
    spoofer = UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new("uatuser.json", "deploy.uat.json")
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

  describe "CommandLine" do
    it "should fails on missing config file" do
      given_partial_config()
      assert_raises Common::ValidationError do
        orchestrator.execute(command_line_arguments)
        command_line_provider = context.get_command_line_provider()
      end
    end

    it "should return CommandLine provider" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      command_line_provider = context.get_command_line_provider()
      command_line_provider.wont_be_nil
    end

    it "should get CommandLine user file content" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      command_line_provider = context.get_command_line_provider()
      command_line_provider.get_user_config_content().wont_be_nil
    end

    it "should get CommandLine deploy file content" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      command_line_provider = context.get_command_line_provider()
    end
  end

  describe "Infrastructure" do
    it "should get all Infrastructure resources" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      infrastructure_provider = context.get_infrastructure_provider()
      infrastructure_provider.get_all_resource_ids().wont_be_empty
    end
  end

  describe "User" do
    it "should get api key" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      user_provider = context.get_user_config_provider()
      user_provider.get_aws_credential().get_api_key().wont_be_empty
    end

    it "should get secret key path" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      user_provider = context.get_user_config_provider()
      user_provider.get_aws_credential().get_secret_key_path().wont_be_empty
    end      
  end

  describe "Service" do
    it "should get all services" do
      given_template_config_files()
      orchestrator.execute(command_line_arguments)
      service_provider = context.get_services_provider()
      service_provider.get_services().wont_be_empty
    end
  end

  def given_user_config()
    command_line_arguments.push("-c")
    local_user_filename = "#{user_config_filename}.local"
    local_user_filepath = UserAcceptanceTests::FileFinder.find_up(local_user_filename, __dir__)
    if local_user_filepath != nil && File.exist?(local_user_filepath)
      command_line_arguments.push(local_user_filepath)
    else
      command_line_arguments.push("user_acceptance_tests/#{user_config_filename}")
    end
  end

  def given_partial_config()
    given_user_config()
    command_line_arguments.push("-l")
    command_line_arguments.push("error")
  end

  def given_template_config_files()
    given_user_config()
    command_line_arguments.push("-d")
    command_line_arguments.push("#{__dir__}/deploy.uat.json")
    command_line_arguments.push("-l")
    command_line_arguments.push("error")
    spoofers.add(UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new("uatuser.json", "deploy.uat.json"))
  end
end
