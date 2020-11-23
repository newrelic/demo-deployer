require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/batch/context_builder"
require "./src/common/tasks/process_output"
require "./src/batch/definitions/deployment"
require "./src/batch/definitions/partition"
require "./src/batch/runner"

describe "Batch::Runner" do
  let(:errors) { [] }
  let(:deployments) { [] }
  let(:partitions ) { [] }
  let(:launch_count) { [] }
  let(:process_launcher) { m = mock(); m }
  let(:context){ Tests::Batch::ContextBuilder.new().build() }
  let(:runner) { Batch::Runner.new(context, process_launcher) }
  let(:on_complete_lambda) { lambda { |all| errors.concat(all)}}

  it "should create runner" do
    runner.wont_be_nil()
  end

  it "should deploy no partitions" do
    runner.deploy([], on_complete_lambda)
    launch_count.length().must_equal(0)
    errors.length().must_equal(0)
  end

  it "should deploy once" do
    given_logger()
    given_deployment("user1.json", "deploy.json")
    given_process_success()
    runner.deploy(partitions, on_complete_lambda)
    launch_count.length().must_equal(1)
    errors.length().must_equal(0)
  end

  it "should deploy 2 on single partition" do
    given_logger()
    partition = given_partition()
    given_success_deployment("user1.json", "deploy.json", partition)
    given_success_deployment("user2.json", "deploy.json", partition)
    runner.deploy(partitions, on_complete_lambda)
    launch_count.length().must_equal(2)
    errors.length().must_equal(0)
  end

  it "should fail 1 out of 2 deploy on single partition" do
    given_logger()
    partition = given_partition()
    given_error_deployment("user1.json", "deploy.json", partition)
    given_success_deployment("user2.json", "deploy.json", partition)
    runner.deploy(partitions, on_complete_lambda)
    launch_count.length().must_equal(2)
    errors.length().must_equal(1)
  end

  it "should attempt all deployment when multiple partitions" do
    given_logger()
    given_error_deployment("user1.json", "deploy.json", given_partition())
    given_error_deployment("user2.json", "deploy.json", given_partition())
    runner.deploy(partitions, on_complete_lambda)
    launch_count.length().must_equal(2)
    errors.length().must_equal(2)
  end

  it "should teardown no partitions" do
    runner.teardown([], on_complete_lambda)
    launch_count.length().must_equal(0)
    errors.length().must_equal(0)
  end

  it "should teardown once" do
    given_logger()
    given_deployment("user1.json", "deploy.json")
    given_process_success()
    runner.teardown(partitions, on_complete_lambda)
    launch_count.length().must_equal(1)
    errors.length().must_equal(0)
  end

  it "should teardown 2 on single partition" do
    given_logger()
    partition = given_partition()
    given_success_deployment("user1.json", "deploy.json", partition)
    given_success_deployment("user2.json", "deploy.json", partition)
    runner.teardown(partitions, on_complete_lambda)
    launch_count.length().must_equal(2)
    errors.length().must_equal(0)
  end

  it "should fail 1 out of 2 teardown on single partition" do
    given_logger()
    partition = given_partition()
    given_error_deployment("user1.json", "deploy.json", partition)
    given_success_deployment("user2.json", "deploy.json", partition)
    runner.teardown(partitions, on_complete_lambda)
    launch_count.length().must_equal(2)
    errors.length().must_equal(1)
  end

  it "should attempt all deployment when multiple partitions" do
    given_logger()
    given_error_deployment("user1.json", "deploy.json", given_partition())
    given_error_deployment("user2.json", "deploy.json", given_partition())
    runner.teardown(partitions, on_complete_lambda)
    launch_count.length().must_equal(2)
    errors.length().must_equal(2)
  end

  def given_success_deployment(user, deploy, partition = nil)
    partition = partition || given_partition()
    deployment = given_deployment(user, deploy, partition)
    given_process_success(deployment)
  end

  def given_error_deployment(user, deploy, partition = nil)
    partition = partition || given_partition()
    deployment = given_deployment(user, deploy, partition)
    given_process_error(deployment)
  end

  def given_process_error(user, deploy, partition = nil)
    partition = partition || given_partition()
    deployment = given_deployment(user, deploy, partition)
    given_process_success(deployment)
  end

  def given_process_success(deployment = nil)
    exit_code = 0
    given_process(exit_code)
  end

  def given_process_error(deployment = nil)
    exit_code = 2
    given_process(exit_code)
  end

  def given_process(exit_code, deployment = nil)
    process_output = Common::Tasks::ProcessOutput.new(exit_code, "", "", "")
    process = mock()
    process.stubs(:start)
    process.stubs(:get_context).returns(deployment)
    process.stubs(:get_execution_time)
    process.stubs(:wait_to_completion).returns(process_output)
    process_launcher.expects(:call).with(anything, anything, anything, (deployment || anything)).returns(count_process_launch(process))
  end

  def count_process_launch(process)
    launch_count.push(1)
    return process
  end

  def given_partition(max_capacity = 10)
    partition = Batch::Definitions::Partition.new(partitions.length+1, max_capacity)
    partitions.push(partition)
    return partition
  end

  def given_deployment(user, deploy, partition = nil)
    deployment = Batch::Definitions::Deployment.new(user, deploy)
    deployments.push(deployment)
    partition = partition || given_partition()
    partition.add_deployment(deployment)
    return deployment
  end

  def given_logger()
    logger = mock()
    Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
    logger.stubs(:debug)
    logger.stubs(:info)
    logger.stubs(:error)
    log_token = mock()
    log_token.stubs(:success)
    log_token.stubs(:error)
    logger.stubs(:task_start).returns(log_token)
  end
end