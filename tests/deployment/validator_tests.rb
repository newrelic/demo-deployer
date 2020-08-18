require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/validator"
require "./tests/context_builder.rb"

describe "Deployment::Validator" do
  let(:command_line_provider) { context.get_command_line_provider() }
  let(:user_config_provider) { context.get_user_config_provider() }
  let(:infrastructure_provider){ context.get_infrastructure_provider() }
  let(:service_provider){ context.get_services_provider() }
  let(:instrumentation_provider){ context.get_instrumentation_provider() }
  let(:app_config_provider) { context.get_app_config_provider() }

  let(:provider_name) { infratructure_provider.get_provider_names }
  let(:service_host_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:ansible_validator) { m = mock(); m.stubs(:execute); m }
  let(:username_validator) { m = mock(); m.stubs(:execute); m }
  let(:deployname_validator) { m = mock(); m.stubs(:execute); m }
  let(:elb_listeners_value_exist_in_services_validator) { m = mock(); m.stubs(:execute); m }
  let(:r53ip_listeners_value_exist_in_services_validator) { m = mock(); m.stubs(:execute); m }
  let(:elb_dependency_on_listener_validator) { m = mock(); m.stubs(:execute); m }
  let(:elb_listeners_same_port_validator) { m = mock(); m.stubs(:execute); m }
  let(:r53ip_listeners_same_port_validator) { m = mock(); m.stubs(:execute); m }
  let(:service_source_path_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:service_deploy_script_path_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:instrumentor_source_path_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:instrumentor_deploy_script_path_exist_validator) { m = mock(); m.stubs(:execute); m }
  let(:service_resource_same_type_validator) { m = mock(); m.stubs(:execute); m }
  let(:provider_validator_factory) { m = mock(); m.stubs(:create_validators).returns([]); m }
  let(:deploy_config_validator) { m = mock(); m.stubs(:execute); m }
  let(:validator) { Deployment::Validator.new(
    service_host_exist_validator,
    username_validator,
    deployname_validator,
    ansible_validator,
    elb_listeners_value_exist_in_services_validator,
    r53ip_listeners_value_exist_in_services_validator,
    elb_dependency_on_listener_validator,
    elb_listeners_same_port_validator,
    r53ip_listeners_same_port_validator,
    service_source_path_exist_validator,
    service_deploy_script_path_exist_validator,
    instrumentor_source_path_exist_validator,
    instrumentor_deploy_script_path_exist_validator,
    service_resource_same_type_validator,
    provider_validator_factory,
    deploy_config_validator)}

  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }

  it "should create validator" do
    validator.wont_be_nil
  end

  describe "execute" do

    it "should execute service_host_exist_validator" do
      service_host_exist_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute username_validator" do
      username_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute deployname_validator" do
      deployname_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute elb_listeners_value_exist_in_services_validator" do
      elb_listeners_value_exist_in_services_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute r53ip_listeners_value_exist_in_services_validator" do
      r53ip_listeners_value_exist_in_services_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute elb_dependency_on_listener_validator" do
      elb_dependency_on_listener_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute elb_listeners_same_port_validator" do
      elb_listeners_same_port_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute r53ip_listeners_same_port_validator" do
      r53ip_listeners_same_port_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute service_source_path_exist_validator" do
      service_source_path_exist_validator.expects(:execute)
      validator.execute(context)
    end
    
    it "should execute deploy_script_path_exist_validator" do
      service_deploy_script_path_exist_validator.expects(:execute)
      validator.execute(context)
    end
    
    it "should execute service_resource_same_type_validator" do
      service_resource_same_type_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute resource_instrumentor_source_path_exist_validator" do
      instrumentor_source_path_exist_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute resource_instrumentor_deploy_script_path_exist_validator" do
      instrumentor_deploy_script_path_exist_validator.expects(:execute)
      validator.execute(context)
    end

    it "should execute deploy_config_validator" do
      deploy_config_validator.expects(:execute)
      validator.execute(context)
    end

  end
end