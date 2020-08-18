require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/provision/actions/pre/aws/provider_factory"
require "./tests/context_builder"

describe "Provision::Actions::Pre::Aws::ProviderFactory" do
  let(:context){ Tests::ContextBuilder.new().user_config().with_aws().build() }
  let(:resource) { m = mock(); m }
  let(:factory) { Provision::Actions::Pre::Aws::ProviderFactory.new(
      context) }

  it "should create factory" do
    factory.wont_be_nil
  end
  
  it "should NOT lookup unsupported" do
    given_resource("special1", "unk")
    instance = factory.create(resource)    
    instance.must_be_nil()
  end

  def given_resource(id, type)
    resource.stubs(:get_id).returns(id)
    resource.stubs(:get_type).returns(type)
  end
end