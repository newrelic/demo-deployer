require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/orchestrator"
require "./tests/context_builder"

describe "Orchestrator" do

  let(:configuration_orchestrator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:provision_orchestrator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:install_instrumentation_orchestrator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:install_orchestrator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:teardown_orchestrator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:summary_orchestrator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:arguments) { [] }

  it "Deploy should execute provision orchestrator" do
    orchestrator = given_arguments_for_deploy()
    provision_orchestrator.expects(:execute)
    orchestrator.execute(arguments)
  end

  it "Deploy should execute install orchestrator" do
    orchestrator = given_arguments_for_deploy()
    install_orchestrator.expects(:execute)
    orchestrator.execute(arguments)
  end

  it "Deploy should execute summary orchestrator" do
    orchestrator = given_arguments_for_deploy()
    summary_orchestrator.expects(:execute)
    orchestrator.execute(arguments)
  end
  
  it "Deploy should NOT execute teardown orchestrator" do
    orchestrator = given_arguments_for_deploy()
    teardown_orchestrator.expects(:execute).never
    orchestrator.execute(arguments)
  end

  it "Teardown should execute teardown orchestrator" do
    orchestrator = given_arguments_for_teardown()
    teardown_orchestrator.expects(:execute)
    orchestrator.execute(arguments)
  end

  it "Teardown should NOT execute provision orchestrator" do
    orchestrator = given_arguments_for_teardown()
    provision_orchestrator.expects(:execute).never
    orchestrator.execute(arguments)
  end

  it "Teardown should NOT execute install orchestrator" do
    orchestrator = given_arguments_for_teardown()
    install_orchestrator.expects(:execute).never
    orchestrator.execute(arguments)
  end

  def given_arguments_for_deploy()
    context = Tests::ContextBuilder.new().user_config().with_aws().build()
    orchestrator = Orchestrator.new(
        context, 
        configuration_orchestrator, provision_orchestrator,
        install_orchestrator,
        teardown_orchestrator, summary_orchestrator)
  end

  def given_arguments_for_teardown()
    context = Tests::ContextBuilder.new()
      .user_config().with_aws()
      .command_line().teardown()
      .build()
    orchestrator = Orchestrator.new(
        context, 
        configuration_orchestrator, provision_orchestrator,
        install_orchestrator,
        teardown_orchestrator, summary_orchestrator)
  end

end