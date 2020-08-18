require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/r53ip_resource"
require "./src/deployment/aws/allowed_reference_validator"
require "./tests/context_builder.rb"

describe "Deployment::Aws::AllowedReferenceValidator" do
  let(:context_builder){ Tests::ContextBuilder.new().user_config().with_aws() }

  it "should not error when no resources defined" do
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should not error when no specified resources defined" do
    given_ec2_resource("host1")
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should not error when specified resource is refering correct type defined" do
    given_r53ip_resource("myservice", "elb1")
    given_elb_resource("elb1")
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should not error when specified resource is refering to a missing resource" do
    given_r53ip_resource("myservice", "elb1")
    validator = given_validator()
    validator.execute(get_resources()).must_be_nil()
  end

  it "should error when specified resource is not of expected type" do
    given_r53ip_resource("myservice", "elb1")
    given_ec2_resource("elb1")
    validator = given_validator()
    error = validator.execute(get_resources())
    error.wont_be_nil()
    error.must_include("elb1")
  end

  def get_context()
    return context_builder.build()
  end

  def given_validator()
    return Deployment::Aws::AllowedReferenceValidator.new(Infrastructure::Definitions::Aws::R53IpResource, ["elb"], get_context())
  end

  def given_ec2_resource(id)
    context_builder.infrastructure().ec2(id, "t2.micro")
  end  
    
  def given_r53ip_resource(id, reference_id)
    context_builder.infrastructure().r53ip_reference(id, "example.newrelic.com", reference_id)
  end

  def given_elb_resource(id, reference_id = nil)
    context_builder.infrastructure().elb(id, reference_id)
  end

  def get_resources()
    resources = get_context().get_infrastructure_provider().get_all()
    return resources
  end

end