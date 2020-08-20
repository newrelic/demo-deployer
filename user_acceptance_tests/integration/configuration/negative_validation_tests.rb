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
require "./user_acceptance_tests/file_finder"

describe "UserAcceptanceTests::NegativeValidationTests" do
  let(:service1) { "service1"}
  let(:host1) { "host1"}
  let(:tmp) { "/tmp"}
  let(:aws) { "aws"}
  let(:port_number) { 8080 }
  let(:arguments) { ["-l", "error"] }
  let(:context) { Context.new() }
  let(:resources) { [] }
  let(:services) { [] }
  let(:user_config_filename) { "uatuser.json" }
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

  it "should fail on resources missing id and unsupported providers" do
    given_resource(host1, "aws")
    given_resource_without_id("aws")
    given_resource_without_id("gcp")
    given_deploy_config()

    error = assert_raises do
      orchestrator.execute(arguments)
    end        

    error.message.must_include("Allowed keys are ")
    error.message.must_include("Resource id is missing")
    error.message.must_include("Missing key")
    error.message.must_include("Key 'gcp' is not currently supported")
  end
  
  it "should fail on services missing host resource and" do
    given_resource(host1, "aws", "ec2", "t2.small")
    given_service(service1, port_number, [host1], tmp, ["service2"])
    given_service_without_id(port_number+1, [host1], tmp, [])
    given_deploy_config()

    error = assert_raises do
      orchestrator.execute(arguments)
    end        

    error.message.must_include("Service id is missing")
    error.message.must_include("The following service relationships are not valid")
  end

  def given_resource_without_id(provider = aws)
    resources.push( {provider: provider} )
  end

  def given_resource(id, provider = nil, type = nil, size = nil)
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
    resources.push(resource)
  end

  def given_service_without_id(port = port_number, host = host1, source = tmp, relationships = [])
    services.push( {port: port_number, destinations:[host], local_source_path:source, relationships:relationships} )
  end

  def given_service(id, port = nil, destinations = nil, source_path = nil, relationships = [])
    service = {id: id}
    unless port.nil?
      service[:port] = port
    end
    unless destinations.nil?
      service[:destinations] = destinations
    end
    unless source_path.nil?
      service[:local_source_path] = source_path
    end
    unless relationships.empty?
      service[:relationships] = relationships
    end
    services.push(service)
  end

  def given_deploy_config()
    arguments.push("-d")
    arguments.push(deploy_config_filename)
    deploy_config_jsonfilebuilder.with("services", services)
    deploy_config_jsonfilebuilder.with("resources", resources)
    deploy_config_jsonfilebuilder.build()
  end

  def given_user_config()
    arguments.push("-c")
    local_user_filename = "#{user_config_filename}.local"
    local_user_filepath = UserAcceptanceTests::FileFinder.find_up(local_user_filename, __dir__)
    if local_user_filepath != nil && File.exist?(local_user_filepath)
      arguments.push(local_user_filepath)
    else
      arguments.push("user_acceptance_tests/#{user_config_filename}")
    end
  end

end