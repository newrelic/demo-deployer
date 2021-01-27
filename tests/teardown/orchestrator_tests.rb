require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/install_error"
require "./src/teardown/orchestrator"
require "./src/common/logger/info_logger"
require "./tests/context_builder"

describe "Teardown::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new().user_config().with_aws().build() }
  let(:directory_service) { m = mock(); m }
  let(:composer) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:terminator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:summary) { m = mock(); m.stubs(:execute); m }
  let(:log_token) { m = mock(); m.stubs(:success).returns(nil); m.stubs(:error).returns(nil);  m }
  let(:post_actions_orchestrator) { m = mock(); m.stubs(:execute); m }
  let(:provision_orchestrator) { m = mock(); m }

  it "should create orchestrator" do
    when_orchestrator().wont_be_nil()
  end

  it "should execute summary" do
    given_logger()
    summary.expects(:execute)
    when_orchestrator().execute()
  end

  def given_logger()
    logger = mock()
    logger.stubs(:debug)
    sub_task = mock()
    sub_task.stubs(:success)

    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.expects(:task_start).returns(log_token)
    logger.stubs(:add_sub_task).returns(sub_task)
  end

  def when_orchestrator()
    provision_provider = context.get_provision_provider()
    provision_orchestrator.stubs(:execute).returns(provision_provider)
    return Teardown::Orchestrator.new(
      context,
      directory_service,
      composer,
      terminator,
      summary,
      post_actions_orchestrator,
      provision_orchestrator)
  end

end