require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/logger/logger_factory"
require "./src/provision/actions/pre/orchestrator"
require "./tests/context_builder"

describe "Provision::Actions::Pre::Orchestrator" do
  let(:context_builder){ Tests::ContextBuilder.new().user_config().with_aws() }
  let(:post_actions_factory) { m = mock(); m.stubs(:create); m }
  let(:lambda_action) { m = mock(); m }

  it "should create orchestrator" do
    when_orchestrator().wont_be_nil
  end

  it "should execute action on supported resource" do
    given_logger()
    given_resource("lambda1", "lambda")
    post_actions_factory.expects(:create).returns(lambda_action)
    lambda_action.expects(:execute)
    when_orchestrator().execute()
  end

  it "should NOT execute action on unsupported resource" do
    given_logger()
    given_resource("special1", "unk")
    when_orchestrator().execute()
  end

  def given_logger()
    logger = mock()
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.stubs(:debug)
  end

  def given_resource(id, type)
    context_builder.infrastructure().with_resource(id, {"provider" => "aws", "type" => "#{type}"})
  end

  def when_orchestrator()
    context = context_builder.build()
    return Provision::Actions::Pre::Orchestrator.new(
      context,
      post_actions_factory)
  end
end