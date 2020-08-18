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

describe "UserAcceptanceTests::Instrumentation" do
  describe "FailedValidation" do
    let(:arguments) { [] }
    let(:context) { Context.new() }
    let(:resource) { create_resource("host1", "aws", "ec2", "t2.small") }
    let(:resources) { [resource] }
    let(:service) { create_service("app1", 8080, ["host1"], "/tmp") }
    let(:services) { [service] }
    let(:credentials) { {} }
    let(:instrumentations) { [] }
    let(:instrumentor_id) { "instrumentor_id" }    
    let(:user_config_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
    let(:deploy_config_filename) { UserAcceptanceTests::JsonFileBuilder.create_filename() }
    let(:user_config_jsonfilebuilder) { UserAcceptanceTests::JsonFileBuilder.new(user_config_filename) }
    let(:deploy_config_jsonfilebuilder) { UserAcceptanceTests::JsonFileBuilder.new(deploy_config_filename) }
    let(:spoofers) { UserAcceptanceTests::Spoofers::TestSpoofers.new([
      user_config_jsonfilebuilder,
      deploy_config_jsonfilebuilder
      ])}
    let(:orchestrator) { ConfigurationOrchestrator.new(context) }

    before do
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

    it "should fail on unsupported instrumentation provider " do
      given_aws_credential("aws", "api_key", "secret_key", "/path", "region")
      given_newrelic_credential("newrelic", "23ABCDE345", "http://")
      given_instrumentation(["host1"], "datapup", "1.2.3", "../tmp", "/tmp", nil)
      given_user_config(credentials)
      given_deploy_config(resources, instrumentations, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("datapup")
    end

    it "should fail on resource_ids not defined" do
      given_aws_credential("aws", "api_key", "secret_key", "/path", "region")
      given_newrelic_credential("newrelic", "23ABCDE345", "http://")
      given_instrumentation([], "newrelic", "1.2.3", "../tmp", "/tmp", nil)
      given_user_config(credentials)
      given_deploy_config(resources, instrumentations, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("resource_ids")
    end

    it "should fail on missing host resource for instrumentation" do
      given_aws_credential("aws", "api_key", "secret_key", "/path", "region")
      given_newrelic_credential("newrelic", "23ABCDE345", "http://")
      given_instrumentation(["missinghost"], "newrelic", "1.2.3", "../tmp", "/tmp", nil)
      given_user_config(credentials)
      given_deploy_config(resources, instrumentations, services)
      error = assert_raises do
        orchestrator.execute(arguments)
      end
      error.message.must_include("missinghost")
    end

    it "should fail on source_repository and local_source_path not defined" do
      given_aws_credential("aws", "api_key", "secret_key", "/path", "region")
      given_newrelic_credential("newrelic", "23ABCDE345", "http://")
      given_instrumentation(["host1"], "newrelic", "1.2.3", "../tmp", nil, nil)
      given_user_config(credentials)
      given_deploy_config(resources, instrumentations, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("source_path")
    end

    it "should fail on deploy_script_path not defined" do
      given_aws_credential("aws", "api_key", "secret_key", "/path", "region")
      given_newrelic_credential("newrelic", "23ABCDE345", "http://")
      given_instrumentation(["host1"], "newrelic", "1.2.3", nil, "/tmp", nil)
      given_user_config(credentials)
      given_deploy_config(resources, instrumentations, services)
      error = assert_raises Common::ValidationError do
        orchestrator.execute(arguments)
      end
      error.message.must_include("deploy_script_path")
    end

    def given_resource(id, provider = nil, type = nil, size = nil)
      resource = create_resource(id, provider, type, size)
      resources.push(resource)
    end

    def create_resource(id, provider = nil, type = nil, size = nil)
      resource = {id: id, deploy_script_path: "../tmp"}
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

    def given_instrumentation(resourceIds = [], provider= nil, version= nil, deploy_script_path = "../tmp", local_source_path= nil, source_repository = nil)
      instrumentation = create_instrumentation(resourceIds, provider, version, deploy_script_path, local_source_path, source_repository)
      instrumentations.push(instrumentation)
    end

    def create_instrumentation(resourceIds = [], provider= nil, version= nil, deploy_script_path = nil, local_source_path= nil, source_repository = nil)
      instrumentation = {}
      instrumentation[:id] = instrumentor_id
      unless resourceIds.nil?
        instrumentation[:resource_ids] = resourceIds
      end
      unless provider.nil?
        instrumentation[:provider] = provider
      end
      unless version.nil?
        instrumentation[:version] = version
      end
      unless local_source_path.nil?
        instrumentation[:local_source_path] = local_source_path
      end
      unless source_repository.nil?
        instrumentation[:source_repository] = source_repository
      end
      unless deploy_script_path.nil?
        instrumentation[:deploy_script_path] = deploy_script_path
      end
      return instrumentation
    end

    def given_deploy_config(resources = [], instrumentations = [], services = [])
      arguments.push("-d")
      arguments.push(deploy_config_filename)
      arguments.push("-l")
      arguments.push("error")
      instrumentation_json = {}
      instrumentation_json["resources"] = instrumentations
      deploy_config_jsonfilebuilder.with("instrumentations", instrumentation_json)
      deploy_config_jsonfilebuilder.with("resources", resources)
      deploy_config_jsonfilebuilder.with("services", services)
      deploy_config_jsonfilebuilder.build()
    end

    def given_user_config(credentials = [], filename = user_config_filename)
      arguments.push("-c")
      arguments.push(filename)
      user_config_jsonfilebuilder.with("credentials", credentials)
      user_config_jsonfilebuilder.build()
    end

    def given_service(id, port = nil, destinations = nil, local_source_path = nil)
      service = create_service(id, port, destinations, local_source_path)
      services.push(service)
    end

    def create_service(id, port = nil, destinations = nil, local_source_path = nil)
      service = {id: id, display_name:"App Name", deploy_script_path: "../tmp"}
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

    def given_newrelic_credential(provider = nil, license_key = nil, collector_url = nil)
      access = { }
      unless license_key.nil?
        access[:licenseKey] = license_key
      end
      unless collector_url.nil?
        access[:collector_url] = collector_url
      end
      credentials[provider] = access
    end

    def given_aws_credential(provider, api_key = nil, secret_key = nil, secret_key_path = nil, region = nil)
      access = { provider: "aws"}
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

  end
end