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

describe "UserAcceptanceTests::Infrastructure" do
  describe "FailedValidation" do
    let(:arguments) { [] }
    let(:context) { Context.new() }
    let(:resources) { [] }
    let(:services) { [] }
    let(:user_config_filename) { "user_acceptance_tests/user.uat.json" }
    let(:deploy_config_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
    let(:deploy_config_jsonfilebuilder) { UserAcceptanceTests::JsonFileBuilder.new(deploy_config_filename) }
    let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new([
      deploy_config_jsonfilebuilder
      ])}
    let(:orchestrator) { ConfigurationOrchestrator.new(context) }

    before do
      given_user_config()
    end

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

    it "should fail on missing resource id" do
      given_resource_without_id()
      given_deploy_config(resources, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("Resource id is missing")
    end
    
    it "should fail on missing provider" do
      given_resource_without_provider("myhost")
      given_deploy_config(resources, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("Missing key")
      error.message.must_include("Allowed keys are")
      error.message.must_include("myhost")
    end
    
    it "should fail on duplicate resource id case insensitive" do
      given_resource("host1")
      given_resource("HOST1")
      given_deploy_config(resources, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("host1")
      error.message.must_include("HOST1")
      error.message.must_include("Duplicate resource_id found")
    end
    
    it "should fail on not supported resource provider type" do
      given_resource("host1", "gws")
      given_deploy_config(resources, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("gws")
      error.message.must_include("not currently supported")
    end
    
    it "should fail on not supported aws resource type" do
      given_resource("host1", "aws", "unsupported_ec2")
      given_deploy_config(resources, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("unsupported_ec2")
      error.message.must_include("not currently supported")
    end
    
    it "should fail on not supported aws resource size" do
      given_resource("host1", "aws", "ec2", "unknown_enormous")
      given_deploy_config(resources, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("unknown_enormous")
      error.message.must_include("resources have an invalid size")
    end
    
    def given_resource(id, provider = nil, type = nil, size = nil)
      resource = {id: id}
      resource[:provider] = provider || "aws"
      unless type.nil?
        resource[:type] = type
      end
      unless size.nil?
        resource[:size] = size
      end
      resources.push(resource)
    end

    def given_resource_without_id()
      resources.push( {provider: "aws", type:"not known", size:"any"} )
    end

    def given_resource_without_provider(id)
      resources.push( {id: id, type:"not known", size:"any"} )
    end

    def given_deploy_config(resources = [], services = [])
      arguments.push("-d")
      arguments.push(deploy_config_filename)
      arguments.push("-l")
      arguments.push("error")
      deploy_config_jsonfilebuilder.with("services", services)
      deploy_config_jsonfilebuilder.with("resources", resources)
      deploy_config_jsonfilebuilder.build()
    end

    def given_user_config()
      arguments.push("-c")
      arguments.push(user_config_filename)
    end

  end
end