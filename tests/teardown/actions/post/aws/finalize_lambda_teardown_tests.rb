require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/teardown/actions/post/aws/finalize_lambda_teardown"

require "./tests/context_builder"

describe "Teardown::Actions::Post::Aws::FinalizeLambdaTeardown" do
  let(:context){ Tests::ContextBuilder.new().user_config().with_aws().build() }
  let(:api_gateway_client) { m = mock(); m.stubs(:delete_api_gateway_by_name); m }
  let(:resource) { m = mock(); m }
  let(:credential) { m = mock(); m }
  let(:action) { Teardown::Actions::Post::Aws::FinalizeLambdaTeardown.new(
      context,
      api_gateway_client,
      lambda{ }) }

  it "should create action" do
    action.wont_be_nil
  end

  it "should delete api gateway" do
    given_logger()
    given_resource("lambda1", "lambda")
    api_gateway_client.expects(:delete_api_gateway_by_name)
    action.execute(resource)
  end

  def given_logger()
    logger = mock()
    sub_task = mock()
    sub_task.stubs(:success)
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.stubs(:debug)
    logger.stubs(:add_sub_task).returns(sub_task)
  end

  def given_resource(id, type)
    resource.stubs(:get_id).returns(id)
    resource.stubs(:get_type).returns(type)
    resource.stubs(:get_credential).returns(credential)
  end

end