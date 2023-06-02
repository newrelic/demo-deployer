require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/batch/context_builder"
require "./src/common/tasks/process_output"
require "./src/common/definitions/deployment"
require "./src/common/definitions/partition"
require './src/common/tasks/runner'

describe "Common::Tasks::Runner" do
  let(:errors) { [] }
  let(:deployments) { [] }
  let(:partitions ) { [] }
  let(:launch_count) { [] }
  let(:process_launcher) { m = mock(); m }
  let(:context){ Tests::Batch::ContextBuilder.new().build() }
  let(:get_output_lambda) { lambda { |deployment| return get_output(deployment)} }
  let(:runner) { Common::Tasks::Runner.new(context, process_launcher, get_output_lambda) }
  let(:on_complete_lambda) { lambda { |all| errors.concat(all)} }
  let(:outputs) { m = mock(); m }

  it "should create runner" do
    runner.wont_be_nil()
  end

  describe "Deploy" do
    let(:is_teardown) { false }

    it "should deploy no partitions" do
      runner.deploy([], on_complete_lambda)
      launch_count.length().must_equal(0)
      errors.length().must_equal(0)
    end
  
    it "should deploy once" do
      given_logger()
      deployment = given_deployment("user1.json", "deploy.json")
      given_process_success(deployment, is_teardown)
      runner.deploy(partitions, on_complete_lambda)
      launch_count.length().must_equal(1)
      errors.length().must_equal(0)
    end
  
    it "should deploy 2 on single partition" do
      given_logger()
      partition = given_partition()
      given_success_deployment("user1.json", "deploy.json", partition, is_teardown)
      given_success_deployment("user2.json", "deploy.json", partition, is_teardown)
      runner.deploy(partitions, on_complete_lambda)
      launch_count.length().must_equal(2)
      errors.length().must_equal(0)
    end
  
    it "should fail 1 out of 2 deploy on single partition" do
      given_logger()
      partition = given_partition()
      given_error_deployment("user1.json", "deploy.json", partition, is_teardown)
      given_success_deployment("user2.json", "deploy.json", partition, is_teardown)
      runner.deploy(partitions, on_complete_lambda)
      launch_count.length().must_equal(2)
      errors.length().must_equal(1)
    end
  
    it "should attempt all deployment when multiple partitions" do
      given_logger()
      given_error_deployment("user1.json", "deploy.json", given_partition(), is_teardown)
      given_error_deployment("user2.json", "deploy.json", given_partition(), is_teardown)
      runner.deploy(partitions, on_complete_lambda)
      launch_count.length().must_equal(2)
      errors.length().must_equal(2)
    end

    it "should not detect failure when process output indicates success" do
      given_logger()
      succeeded = runner.has_deployment_succeeded?("something whatever but Deployment successful! so this is ok", is_teardown)
      succeeded.must_equal(true)
    end
  
    it "should detect failure when process output does NOT indicates success" do
      given_logger()
      succeeded = runner.has_deployment_succeeded?("something without any indication of success.", is_teardown)
      succeeded.must_equal(false)
    end
  end

  describe "Teardown" do
    let(:is_teardown) { true }

    it "should teardown no partitions" do
      runner.teardown([], on_complete_lambda)
      launch_count.length().must_equal(0)
      errors.length().must_equal(0)
    end
  
    it "should teardown once" do
      given_logger()
      deployment = given_deployment("user1.json", "deploy.json")
      given_process_success(deployment, is_teardown)
      runner.teardown(partitions, on_complete_lambda)
      launch_count.length().must_equal(1)
      errors.length().must_equal(0)
    end
  
    it "should teardown 2 on single partition" do
      given_logger()
      partition = given_partition()
      given_success_deployment("user1.json", "deploy.json", partition, is_teardown)
      given_success_deployment("user2.json", "deploy.json", partition, is_teardown)
      runner.teardown(partitions, on_complete_lambda)
      launch_count.length().must_equal(2)
      errors.length().must_equal(0)
    end
  
    it "should fail 1 out of 2 teardown on single partition" do
      given_logger()
      partition = given_partition()
      given_error_deployment("user1.json", "deploy.json", partition, is_teardown)
      given_success_deployment("user2.json", "deploy.json", partition, is_teardown)
      runner.teardown(partitions, on_complete_lambda)
      launch_count.length().must_equal(2)
      errors.length().must_equal(1)
    end
  
    it "should attempt all deployment when multiple partitions" do
      given_logger()
      given_error_deployment("user1.json", "deploy.json", given_partition(), is_teardown)
      given_error_deployment("user2.json", "deploy.json", given_partition(), is_teardown)
      runner.teardown(partitions, on_complete_lambda)
      launch_count.length().must_equal(2)
      errors.length().must_equal(2)
    end

    it "should not detect failure when process output indicates success for teardown" do
      given_logger()
      succeeded = runner.has_deployment_succeeded?("something whatever but Teardown successful! so this is ok", is_teardown)
      succeeded.must_equal(true)
    end
  
    it "should detect failure when process output does NOT indicates success for teardown" do
      given_logger()
      succeeded = runner.has_deployment_succeeded?("something without any indication of success.", is_teardown)
      succeeded.must_equal(false)
    end
  end

  def given_success_deployment(user, deploy, partition, is_teardown)
    partition = partition || given_partition()
    deployment = given_deployment(user, deploy, partition)
    given_process_success(deployment, is_teardown)
  end

  def given_error_deployment(user, deploy, partition, is_teardown)
    partition = partition || given_partition()
    deployment = given_deployment(user, deploy, partition)
    given_process_error(deployment)
  end

  def given_process_success(deployment, is_teardown)
    exit_code = 0
    if is_teardown
      outputs.stubs(:get).with(deployment).returns(" Teardown successful! ")
    else
      outputs.stubs(:get).with(deployment).returns(" Deployment successful! ")
    end
    given_process(exit_code, deployment)
  end

  def given_process_error(deployment)
    exit_code = 2
    outputs.stubs(:get).with(deployment).returns("Something went wrong")
    given_process(exit_code, deployment)
  end

  def get_output(deployment)
    return outputs.get(deployment)
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
    partition = Common::Definitions::Partition.new(partitions.length+1, max_capacity)
    partitions.push(partition)
    return partition
  end

  def given_deployment(user, deploy, partition = nil)
    deployment = Common::Definitions::Deployment.new(user, deploy)
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