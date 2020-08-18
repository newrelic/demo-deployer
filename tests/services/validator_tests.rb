require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/validator"
require "./tests/context_builder.rb"


describe "Services::Validator" do
  let(:services) { [] }
  let(:resources) { [] }
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:service_id_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:app_config_provider) { m = mock(); m.stubs(:get_service_id_max_length).returns(10) ; m }
  let(:unique_id_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:deploy_script_path_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:port_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:destination_exist_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:relationships_validator) { m = mock(); m.stubs(:execute) ; m }
  let(:id_alphanumeric_validator) { m = mock(); m.stubs(:execute) ; m }  
  let(:service_id_length_validation) { nil }
  let(:source_validator) { m = mock(); m.stubs(:execute) ; m }

  let(:validator) { Services::Validator.new(
      context,
      service_id_validator,
      unique_id_validator,
      deploy_script_path_validator,
      port_validator,
      destination_exist_validator,
      relationships_validator,
      service_id_length_validation,
      source_validator,
      id_alphanumeric_validator
  )
  }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should services have id" do
    service_id_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end

  it "should validate service ids are unique" do
    unique_id_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end
  
  it "should validate have a deploy script path" do
    deploy_script_path_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end

  it "should validate services port" do
    port_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end

  it "should validate services destination exist" do
    destination_exist_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end

  it "should validate relationships" do
    relationships_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end

  it "should validate service id max length" do
    expect(validator.send(:get_service_id_length_validator, app_config_provider).execute(services))
  end

  it "should services have existing source_validator" do
    source_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end
  
  it "should services have existing id_alphanumeric_validator" do
    id_alphanumeric_validator.expects(:execute)
    validator.execute(services, resources, app_config_provider)
  end
  
end