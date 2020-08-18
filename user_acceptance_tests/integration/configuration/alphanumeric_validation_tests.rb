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

describe "UserAcceptanceTests::Deployment" do
  describe "FailedAlphanumericValidation" do
    let(:arguments) { [] }
    let(:context) { Context.new() }
    let(:resources) { [] }
    let(:services) { [] }
    let(:invalid_filename) { "Not!Alpha!Numeric.json" }
    let(:valid_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
    let(:api_key) { "api key content"}
    let(:secret_key) { "private key content"}
    let(:secret_key_path) { "private key path"}
    let(:region) { "portland level 22"}
    let(:credentials) { {} }
    let(:user_config_jsonfilebuilder) { nil }
    let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new( [
    ] )}
    let(:orchestrator) { ConfigurationOrchestrator.new(context) }

    before do
      FileUtils.stubs(:cp_r)
    end

    after do
      spoofer1 = UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new(invalid_filename, valid_filename)
      spoofer2 = UserAcceptanceTests::Spoofers::DeploymentDirectorySpoofer.new(valid_filename, invalid_filename)
      app_config_provider = context.get_app_config_provider()
      if (app_config_provider != nil)
        path = context.get_app_config_provider().get_execution_path()
        spoofer1.set_directory_path(path)
        spoofer2.set_directory_path(path)
      end
      spoofers.add(spoofer1)
      spoofers.add(spoofer2)
      spoofers.dispose()
    end

    it "should create orchestrator" do
      orchestrator.wont_be_nil
    end

    it "should fail on non alphanumeric user config filename" do
      given_credential("aws", api_key, secret_key, secret_key_path, region)
      given_user_config(credentials, invalid_filename)
      given_resource("host1", "aws", "ec2", "t2.small")
      given_service("app1", 8080, ["host1"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("User configuration file name")
    end

    it "should fail on non alphanumeric deploy config filename" do
      given_credential("aws", api_key, secret_key, secret_key_path, region)
      given_user_config(credentials)
      given_resource("host1", "aws", "ec2", "t2.small")
      given_service("app1", 8080, ["host1"], "/tmp")
      given_deploy_config(resources, services, invalid_filename)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("Deploy configuration file name")
    end

  end

  def given_resource(id, provider = nil, type = nil, size = nil)
    resource = create_resource(id, provider, type, size)
    resources.push(resource)
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

  def given_service(id, port = nil, destinations = nil, local_source_path = nil)
    service = create_service(id, port, destinations, local_source_path)
    services.push(service)
  end

  def create_service(id, port = nil, destinations = nil, local_source_path = nil)
    service = {id: id, display_name: "App Name", deploy_script_path: "../tmp"}
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

  def given_deploy_config(resources = [], services = [], filename = valid_filename)
    arguments.push("-d")
    arguments.push(filename)
    arguments.push("-l")
    arguments.push("error")
    deploy_config_jsonfilebuilder = UserAcceptanceTests::JsonFileBuilder.new(filename)
    spoofers.add(deploy_config_jsonfilebuilder)
    deploy_config_jsonfilebuilder.with("services", services)
    deploy_config_jsonfilebuilder.with("resources", resources)
    deploy_config_jsonfilebuilder.build()
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
      access[:secretKeyPath] = "./user_acceptance_tests/secret_file.pem"
    end
    unless region.nil?
      access[:region] = region
    end
    credentials[provider] = access
  end

  def given_user_config(credentials = [], filename = valid_filename)
    arguments.push("-c")
    arguments.push(filename)
    user_config_jsonfilebuilder = UserAcceptanceTests::JsonFileBuilder.new(filename)
    spoofers.add(user_config_jsonfilebuilder)
    user_config_jsonfilebuilder.with("credentials", credentials)
    user_config_jsonfilebuilder.build()
  end

end