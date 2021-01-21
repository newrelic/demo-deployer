require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/provision/orchestrator"
require "./tests/context_builder"

describe "Provision::Orchestrator" do
  let(:context) { Tests::ContextBuilder.new().build() }
  let(:directory_service) { m = mock(); m.stubs(:create_sub_directory).returns("/path"); m }
  let(:provisioner) { m = mock(); m.stubs(:execute); m.stubs(:set_info_logger_token); m }
  let(:composer) { m = mock(); m.stubs(:execute); m }
  let(:log_token) { m = mock(); m.stubs(:success).returns(nil); m.stubs(:error).returns(nil);  m }
  let(:pre_actions_orchestrator) { m = mock(); m.stubs(:execute); m }
  let(:orchestrator) { Provision::Orchestrator.new(context, directory_service, provisioner, composer, pre_actions_orchestrator) }
  let(:infrastructure_provider) { m = mock() }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do
    it "should return provision provider" do
      given_logger()
      ret = orchestrator.execute()
      assert_kind_of(Provision::Provider, ret)
    end
  end

  def given_logger()
    logger = mock()
    logger.stubs(:debug)
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.expects(:task_start).returns(log_token)
  end
end