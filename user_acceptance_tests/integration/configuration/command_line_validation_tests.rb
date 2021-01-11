require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/validation_error"
require "./src/configuration_orchestrator"
require "./src/context"

require "./user_acceptance_tests/json_file_builder"
require "./user_acceptance_tests/spoofers/file_spoofer"
require "./user_acceptance_tests/spoofers/deployment_directory_spoofer"
require "./user_acceptance_tests/spoofers/test_spoofers"

describe "UserAcceptanceTests::CommandLine::FailedValidation" do
  let(:arguments) { [] }
  let(:context) { Context.new() }
  let(:user_config_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
  let(:deploy_config_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
  let(:user_config_jsonfilebuilder) { UserAcceptanceTests::JsonFileBuilder.new(user_config_filename) }
  let(:deploy_config_jsonfilebuilder) { UserAcceptanceTests::JsonFileBuilder.new(deploy_config_filename) }
  let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new([
    user_config_jsonfilebuilder,
    deploy_config_jsonfilebuilder
    ])}
  let(:orchestrator) { ConfigurationOrchestrator.new(context) }

  after do
    spoofer = UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new(user_config_filename, deploy_config_filename)
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

  it "should fail on missing deploy configuration" do
    given_user_config()
    error = assert_raises Common::ValidationError do
      orchestrator.execute(arguments)
    end
    error.message.must_include("No deploy config file defined")
  end

  it "should fail on missing user configuration" do
    given_deploy_config()
    error = nil
    Dir.stub(:glob, []) do
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
    end
    error.message.must_include("No user config file found")
  end

  it "should fail too many user configurations" do
    given_deploy_config()
    error = nil
    Dir.stub(:glob, ['configs/one.configurations.local.json','configs/two.configurations.local.json']) do
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
    end
    error.message.must_include("Too many user config files found")
  end

  def given_user_config()
    arguments.push("-c")
    arguments.push(user_config_filename)
    arguments.push("-l")
    arguments.push("error")
    user_config_jsonfilebuilder.with("credentials", {})
    user_config_jsonfilebuilder.build()
  end

  def given_deploy_config()
    arguments.push("-d")
    arguments.push(deploy_config_filename)
    arguments.push("-l")
    arguments.push("error")
    deploy_config_jsonfilebuilder.with("services", [])
    deploy_config_jsonfilebuilder.with("resources", [])
    deploy_config_jsonfilebuilder.build()
  end
end