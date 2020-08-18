require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/teardown/actions/post/aws/provider_factory"
require "./src/teardown/actions/post/aws/finalize_lambda_teardown"
require "./tests/context_builder"

describe "Teardown::Actions::Post::Aws::ProviderFactory" do
  let(:context){ Tests::ContextBuilder.new().user_config().with_aws().build() }
  let(:resource) { m = mock(); m }
  let(:factory) { Teardown::Actions::Post::Aws::ProviderFactory.new(
      context) }

  it "should create factory" do
    factory.wont_be_nil
  end

  it "should lookup supported type" do
    given_resource("lambda1", "lambda")
    instance = factory.create(resource)    
    assert_kind_of(Teardown::Actions::Post::Aws::FinalizeLambdaTeardown, instance)
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