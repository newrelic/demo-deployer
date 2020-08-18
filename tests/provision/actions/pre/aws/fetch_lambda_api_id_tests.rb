require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/provision/actions/pre/aws/fetch_lambda_api_id"

require "./tests/context_builder"

describe "Provision::Actions::Pre::Aws::FetchLambdaApiId" do
  let(:context_builder){ Tests::ContextBuilder.new().user_config().with_aws() }
  let(:api_gateway_client) { m = mock(); m.stubs(:delete_api_gateway_by_name); m }
  let(:resource) { m = mock(); m }
  let(:credential) { m = mock(); m }
  let(:api_id) { "668d51eb-6fc4-4d7c-9745-721e6593fa15" }

  it "should create action" do
    when_action().wont_be_nil
  end

  it "should lookup api_id" do
    given_logger()
    given_resource("lambda1", "lambda")
    api_gateway_client.expects(:get_api_gateway_id_by_name).returns(api_id)
    when_action().execute(resource)
  end

  def given_logger()
    logger = mock()
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.stubs(:debug)
  end
  
  def given_resource(id, type)
    context_builder.infrastructure().with_resource(id, {"provider" => "aws", "type" => "#{type}"})
    resource.stubs(:get_id).returns(id)
    resource.stubs(:get_type).returns(type)
    resource.stubs(:get_credential).returns(credential)
    resource.stubs(:set_api_id).with(api_id)
  end

  def when_action()
    context = context_builder.build()
    return Provision::Actions::Pre::Aws::FetchLambdaApiId.new(
      context, 
      api_gateway_client)
  end
end