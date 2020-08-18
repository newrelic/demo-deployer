require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/provision/actions/pre/aws/provider_factory"

require "./tests/context_builder"

describe "Provision::Actions::Pre::PreActionsFactory" do
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:instance) { m = mock(); m.stubs(:create); m }
  let(:aws_factory) { m = mock(); m }
  let(:supported_types) { { "aws" => aws_factory } }
  let(:factory) { Provision::Actions::Pre::PreActionsFactory.new(
    context,
    supported_types)}

  it "should create factory" do
    factory.wont_be_nil()
  end
  
  it "should NOT lookup unsupported" do
    resource = given_resource("special1", "gcp")
    instance = factory.create(resource)
    instance.must_be_nil()
  end

  def given_resource(id, provider)
    resource = mock()
    resource.stubs(:get_id).returns(id)
    resource.stubs(:get_provider).returns(provider)
    return resource
  end

end