require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/infrastructure/definitions/aws/lambda_resource"
require "./src/deployment/aws/allowed_listeners_validator"
require "./tests/context_builder.rb"

describe "Deployment::Aws::AllowedListenersValidator" do
  let(:context_builder){ Tests::ContextBuilder.new()
    .user_config().with_aws() 
    .infrastructure().ec2("host1")
    .services().service("app1", 5000, "src/path", "deploy", ["host1"])
  }

  it "should not error when no resources or services defined" do
    given_elb_resource("app_elb", ["app1"])
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should not error if no ELB defined" do
    given_lambda_resource("app_lambda1")
    given_lambda_resource("app_lambda2")
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should not error if listener refers to an EC2 resource" do
    given_elb_resource("elb_resource", ['app1'])
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should error if listener includes lambda listener dependency" do
    given_lambda_resource("app_lambda1")
    given_lambda_service("lambda_service1", "app_lambda1")
    given_elb_resource('app_elb', ["lambda_service1"])
    validator = given_validator()
    error = validator.execute(get_resources())
    error.must_include('lambda_service1')
  end

  it "should error if listener includes lambda listener dependency but not on the ec2 listener dependency" do
    given_lambda_resource("app_lambda1")
    given_lambda_service("lambda_service1", "app_lambda1")
    given_elb_resource('app_elb', ["lambda_service1", "app1"])
    validator = given_validator()
    error = validator.execute(get_resources())
    error.must_include('lambda_service1')
    error.wont_include('app1')
  end

  it "should error twice if two resources include search value and dependency doesn't exist" do
    given_lambda_resource("app_lambda1")
    given_lambda_service("lambda_service1", "app_lambda1")
    given_elb_resource('app_elb1', ['lambda_service1'])
    given_lambda_resource("app_lambda2")
    given_lambda_service("lambda_service2", "app_lambda2")
    given_elb_resource('app_elb2', ['lambda_service2'])
    validator = given_validator()
    error = validator.execute(get_resources())
    error.must_include('lambda_service1')
    error.must_include('lambda_service2')
  end

  def get_context()
    return context_builder.build()
  end

  def given_validator()
    context = get_context()
    services = context.get_services_provider().get_all()
    return Deployment::Aws::AllowedListenersValidator.new(Infrastructure::Definitions::Aws::ElbResource, services, get_context())
  end
  
  def given_service(service_id = 'app1', destinations= ['host1'])
    port = 5000
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations)
  end

  def given_lambda_service(service_id, destination)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().lambda(service_id, local_source_path, deploy_script_path, destination)
  end

  def given_ec2_resource(id = 'host1')
    context_builder.infrastructure().ec2(id, "t2.micro")
  end  

  def given_elb_resource(id, reference_id = nil)
    context_builder.infrastructure().elb(id, reference_id)
  end

  def given_lambda_resource(id = 'app_lambda')
    context_builder.infrastructure().lambda(id)
  end

  def get_resources()
    resources = get_context().get_infrastructure_provider().get_all()
    return resources
  end

end