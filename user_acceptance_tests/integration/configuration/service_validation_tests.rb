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

describe "UserAcceptanceTests::Service" do
  describe "FailedValidation" do
    let(:arguments) { [] }
    let(:context) { Context.new() }
    let(:resource) { create_resource("host1", "aws", "ec2", "t2.small") }
    let(:resources) { [resource] }
    let(:services) { [] }
    let(:api_key) { "api key content"}
    let(:secret_key) { "private key content"}
    let(:secret_key_path) { "private key path"}
    let(:region) { "portland level 22"}
    let(:credentials) { {} }
    let(:user_config_filename) { "user_acceptance_tests/user.uat.json" }
    let(:deploy_config_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
    let(:deploy_config_jsonfilebuilder) { UserAcceptanceTests::JsonFileBuilder.new(deploy_config_filename) }
    let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new([
      deploy_config_jsonfilebuilder
      ])}
    let(:orchestrator) { ConfigurationOrchestrator.new(context) }

    before do
      given_credential("aws", api_key, secret_key, secret_key_path, region)
      given_user_config(credentials)
      FileUtils.stubs(:cp_r)
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

    it "should fail on service missing service id" do
      given_service_without_id()
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("Service id is missing")
    end

    it "should fail on service missing source path" do
      given_service("app1", 8080, ["host1"])
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("At least 1 not Null or Empty having any local_source_path")
    end    

    it "should fail on duplicate service id case insensitive" do
      given_service("app1", 8080, ["host1"], "/tmp")
      given_service("APP1", 1443, ["host2"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("Duplicate service_id found")
    end

    it "should fail on missing destination" do
      given_service("app1", 8080, nil, "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("no destination defined")
    end

    it "should fail on empty destination" do
      given_service("app1", 8080, [], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("no destination defined")
    end

    it "should fail on service missing port" do
      given_service("app1", nil, ["host1"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("missing a port definition")
    end

    it "should fail on service negative port" do
      given_service("app1", -8080, ["host1"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("port assignment that does not fall within these ranges")
    end

    it "should fail on service port of 0" do
      given_service("app1", 0, ["host1"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("port assignment that does not fall within these ranges")
    end

    it "should fail on service port invalid" do
      given_service("app1", "not a port number", ["host1"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("require a valid integer for port number")
    end

    it "should fail on services having same port defined for same host" do
      given_service("app1", 8080, ["host1"], "/tmp")
      given_service("app2", 8080, ["host1"], "/tmp")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("multiple services on the same port")
    end

    it "should fail on service having relationship to non existent service" do
      given_service("app1", 8080, ["host1"], "/tmp", ['app6'])
      given_service("app2", 1443, ["host1"], "/tmp", [])
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("service relationships are not valid")
    end

    it "should fail on service not having any source defined" do
      given_service("app1", 8080, ["host1"], nil, [])
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("At least 1 not Null or Empty")
      error.message.must_include("local_source_path")
      error.message.must_include("source_repository")
    end
    
    it "should fail on service having both a local source path and a source repository" do
      given_service("app1", 8080, ["host1"], "/tmp", [], "git@repo.git")
      given_deploy_config(resources, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("At most 1 not Null and Defined")
      error.message.must_include("/tmp")
      error.message.must_include("git@repo")
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

    def given_service_without_id()
      services.push( {port: 8080, destinations:["host1"], local_source_path:"/tmp", deploy_script_path: "../tmp"} )
    end

    def given_service(id, port = nil, destinations = nil, local_source_path = nil, relationships = [], source_repository = nil)
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
      unless source_repository.nil?
        service[:source_repository] = source_repository
      end
      unless relationships.empty?
        service[:relationships] = relationships
      end
      services.push(service)
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

    def given_credential(provider, api_key = nil, secret_key = nil, secret_key_path = nil, region = nil)
      access = { }
      unless api_key.nil?
        access[:apiKey] = api_key
      end
      unless secret_key.nil?
        access[:secretKey] = secret_key
      end
      unless secret_key_path.nil?
        access[:secretKeyPath] = secret_key_path
      end
      unless region.nil?
        access[:region] = region
      end
      credentials[provider] = access
    end

    def given_user_config(credentials = [], filename = user_config_filename)
      arguments.push("-c")
      arguments.push(filename)
    end

  end
end