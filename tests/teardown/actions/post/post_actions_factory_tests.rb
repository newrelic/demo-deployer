require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/teardown/actions/post/aws/provider_factory"

describe "Teardown::Actions::Post::PostActionsFactory" do
  let(:context) { m = mock(); m }
  let(:instance) { m = mock(); m.stubs(:create); m }
  let(:aws_factory) { m = mock(); m }
  let(:supported_types) { { "aws" => aws_factory } }

  it "should create factory" do
    when_factory().wont_be_nil
  end

  it "should lookup supported type" do
    resource = given_resource("lambda1", "aws")
    aws_factory.expects(:new).returns(instance)
    when_factory().create(resource)
  end
  
  it "should NOT lookup unsupported" do
    resource = given_resource("special1", "unk")
    instance = when_factory().create(resource)
    instance.must_be_nil()
  end

  def given_resource(id, provider)
    resource = mock()
    resource.stubs(:get_id).returns(id)
    resource.stubs(:get_provider).returns(provider)
    return resource
  end

  def when_factory()
    return Teardown::Actions::Post::PostActionsFactory.new(
      context,
      supported_types)
  end

end