require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/logger/logger_factory"
require "./src/teardown/actions/post/orchestrator"
require "./tests/context_builder"

describe "Teardown::Actions::Post::Orchestrator" do
  let(:context_builder){ Tests::ContextBuilder.new()
    .user_config().with_aws()
  }
  let(:post_actions_factory) { m = mock(); m.stubs(:create); m }
  let(:action) { m = mock(); m }

  it "should create orchestrator" do
    when_orchestrator().wont_be_nil
  end

  it "should execute action on supported resource" do
    given_logger()
    given_resource("host1")
    post_actions_factory.expects(:create).returns(action)
    action.expects(:execute)
    when_orchestrator().execute()
  end

  it "should NOT execute action on unsupported resource" do
    given_logger()
    when_orchestrator().execute()
  end

  def given_logger()
    logger = mock()
    sub_task = mock()
    sub_task.stubs(:success)
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.stubs(:debug)
    logger.stubs(:add_sub_task).returns(sub_task)
  end

  def given_resource(id)
    context_builder.infrastructure().ec2(id)
  end

  def when_orchestrator()
    context = context_builder.build()
    return Teardown::Actions::Post::Orchestrator.new(
      context,
      post_actions_factory)
  end

end