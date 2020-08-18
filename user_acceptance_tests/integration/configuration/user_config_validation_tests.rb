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

describe "UserAcceptanceTests::UserConfig" do
  describe "FailedValidation" do
    let(:arguments) { [] }
    let(:context) { Context.new() }
    let(:resource) { create_resource("host1", "aws", "ec2", "t2.small") }
    let(:resources) { [resource] }
    let(:service) { create_service("app1", 8080, ["host1"], "/tmp") }
    let(:services) { [service] }
    let(:api_key) { "api key content"}
    let(:secret_key) { "private key content"}
    let(:secret_key_path) { "private key path"}
    let(:region) { "portland level 22"}
    let(:credentials) { {} }
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

    it "should fail on missing credentials" do
      given_user_config_with_no_credentials()
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("Configuration file is missing credentials section")
    end

    it "should fail on missing api key" do
      given_credential("aws", nil, secret_key, secret_key_path, region)
      given_user_config(credentials)
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("apiKey")
    end
    
    it "should fail on missing secret key" do
      given_credential("aws", api_key, nil, secret_key_path, region)
      given_user_config(credentials)
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("secretKey")
    end

    it "should fail on missing secret key path" do
      given_credential("aws", api_key, secret_key, nil, region)
      given_user_config(credentials)
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("secretKeyPath")
    end
    
    it "should fail on missing region" do
      given_credential("aws", api_key, secret_key, secret_key_path, nil)
      given_user_config(credentials)
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end        
      error.message.must_include("region")
    end
    
  end
  
  def create_resource(id, provider = nil, type = nil, size = nil)
    resource = {id: id}
    unless provider.nil?
      resource[:provider] = provider
    end
    unless type.nil?
      resource[:type] = type
    end
    unless size.nil?
      resource[:size] = size
    end
    return resource
  end

  def create_service(id, port = nil, destinations = nil, local_source_path = nil)
    service = {id: id, deploy_script_path: "/deploy"}
    unless port.nil?
      service[:port] = port
    end
    unless destinations.nil?
      service[:destinations] = destinations
    end
    unless local_source_path.nil?
      service[:local_source_path] = local_source_path
    end
    return service
  end

  def given_credential(provider, api_key = nil, secret_key = nil, secret_key_path = nil, region = nil)
    access = { }
    unless api_key.nil?
      access[:apiKey] = api_key
    end
    unless secret_key.nil?
      access[:secretKey] = secret_key
    end
    unless secret_key_path.nil?
      access[:secretKeyPath] = "user_acceptance_tests/secret_file.pem"
    end
    unless region.nil?
      access[:region] = region
    end
    credentials[provider] = access
  end

  def given_user_config(credentials = [], filename = user_config_filename)
    arguments.push("-c")
    arguments.push(filename)
    user_config_jsonfilebuilder.with("credentials", credentials)
    user_config_jsonfilebuilder.build()
  end
  
  def given_user_config_with_no_credentials()
    arguments.push("-c")
    arguments.push(user_config_filename)
    user_config_jsonfilebuilder.build()
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
end