require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/aws/type_validator_factory"

describe "Deployment::Aws::TypeValidatorFactory" do
  let(:resources) { [] }
  let(:supported_types) { {} }
  let(:services) { [] }
  let(:context) { m = mock(); m }
  let(:factory) { Deployment::Aws::TypeValidatorFactory.new(services, context) }
  
  it "should create validator" do
    factory.wont_be_nil
  end

  it "should create empty array when no resources type" do
    factory.create_validators(resources).must_be_empty()
  end

  it "should allow supported type" do
    given_resource("id1", "lambda")
    factory.create_validators(resources).count.must_equal(1)
  end

  it "should create error validator when type is missing" do
    given_resource_without_type("id1")
    validators = factory.create_validators(resources)

    result = validators[0].call()

    result.wont_be_empty()
    result.must_include("id1")
  end

  def given_resource(id, type = nil)
    resources.push({"id"=> id, "type" => type})
  end

  def given_resource_without_type(id)
    resources.push({"id"=> id})
  end

end