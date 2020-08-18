require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "minitest/hooks"

require "./user_acceptance_tests/assertions/service_behavior_response"
require "./user_acceptance_tests/deployment_manager"

describe "UserAcceptanceTests::Aws::Behaviors" do
  include Minitest::Hooks
  
  before(:all) do
    @deployment_manager = DeploymentManager.new("behaviors.uat.json", __dir__)
    @deployment_manager.deploy()
  end

  after(:all) do
    @deployment_manager.teardown()
  end

  after do
    @deployment_manager.after_each()
  end

  # The reason this file is not broken out into nested `describe` blocks is because
  # the before(:all) and after(:all) hooks run before the tests in each describe block.
  # We only want to deply these services once, so only one describe block is used for these tests.

  # START COMPUTE SECTION
  ## START PYTHONTRON SECTION

  it "Compute pythontron computes for at least the minimum time (targeted behavior)" do
    start_time = Time.now()
      UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
        "api/inventory",
        "pythontron",
        {"X-DEMO-COMPUTE-POST-pythontron": "[1000,2000]"},
        lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
      )
  end

  it "Compute pythontron computes for at least the minimum time non range value" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {"X-DEMO-COMPUTE-POST-pythontron": "[1000,1000]"},
      lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute pythontron computes for at least the minimum time (general behavior)" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {"X-DEMO-COMPUTE-PRE": "[1000,2000]"},
      lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute pythontron does not compute when app id does not match" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {"X-DEMO-COMPUTE-POST-NOTTRON": "[1000,2000]"},
      lambda { |response, service_id| check_max_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute pythontron does not compute when no behaviors are passed" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {},
      lambda { |response, service_id| check_max_response_time(response, service_id, start_time, 1000) }
    )
  end

  ## END PYTHONTRON SECTION

  ## START NODETRON SECTION

  it "Compute nodetron computes for at least the minimum time (targeted behavior)" do
    start_time = Time.now()
      UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
        "api/inventory",
        "nodetron",
        {"X-DEMO-COMPUTE-POST-NODETRON": "[1000,2000]"},
        lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
      )
  end

  it "Compute nodetron computes for at least the minimum time non range value" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {"X-DEMO-COMPUTE-POST-NODETRON": "[1000,1000]"},
      lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute nodetron computes for at least the minimum time (general behavior)" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {"X-DEMO-COMPUTE-PRE": "[1000,2000]"},
      lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute nodetron does not compute when app id does not match" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {"X-DEMO-COMPUTE-POST-NOTTRON": "[1000,2000]"},
      lambda { |response, service_id| check_max_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute nodetron does not compute when no behaviors are passed" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {},
      lambda { |response, service_id| check_max_response_time(response, service_id, start_time, 1000) }
    )
  end

  ## END NODETRON SECTION

  ## START JAVATRON SECTION

  it "Compute javatron computes for at least the minimum time (targeted behavior)" do
    start_time = Time.now()
      UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
        "api/inventory",
        "javatron",
        {"X-DEMO-COMPUTE-POST-javatron": "[1000,2000]"},
        lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
      )
  end

  it "Compute javatron computes for at least the minimum time non range value" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {"X-DEMO-COMPUTE-POST-javatron": "[1000,1000]"},
      lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute javatron computes for at least the minimum time (general behavior)" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {"X-DEMO-COMPUTE-PRE": "[1000,2000]"},
      lambda { |response, service_id| check_min_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute javatron does not compute when app id does not match" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {"X-DEMO-COMPUTE-POST-NOTTRON": "[1000,2000]"},
      lambda { |response, service_id| check_max_response_time(response, service_id, start_time, 1000) }
    )
  end

  it "Compute javatron does not compute when no behaviors are passed" do
    start_time = Time.now()
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {},
      lambda { |response, service_id| check_max_response_time(response, service_id, start_time, 1000) }
    )
  end

  ## END JAVATRON SECTION
  # END COMPUTE SECTION

  # START THROW SECTION
  ## START PYTHONTRON SECTION

  it "Throw pythontron throws error (targeted behavior)" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {"X-DEMO-THROW-POST-pythontron": ""},
      lambda { |response, service_id| check_response_failed(response, service_id) }
    )
  end

  it "Throw pythontron throws error (general behavior)" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {"X-DEMO-THROW-PRE": ""},
      lambda { |response, service_id| check_response_failed(response, service_id) }
    )
  end

  it "Throw pythontron does not throw error when app id does not match" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {"X-DEMO-THROW-POST-NOTRON": ""},
      lambda { |response, service_id| check_response_succeded(response, service_id) }
    )
  end

  it "Throw pythontron does not throw error when no headers are passed" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "pythontron",
      {},
      lambda { |response, service_id| check_response_succeded(response, service_id) }
    )
  end

  ## END PYTHONTRON SECTION

  ## START NODETRON SECTION

  it "Throw nodetron throws error (targeted behavior)" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {"X-DEMO-THROW-POST-NODETRON": ""},
      lambda { |response, service_id| check_response_failed(response, service_id) }
    )
  end

  it "Throw nodetron throws error (general behavior)" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {"X-DEMO-THROW-PRE": ""},
      lambda { |response, service_id| check_response_failed(response, service_id) }
    )
  end

  it "Throw nodetron does not throw error when app id does not match" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {"X-DEMO-THROW-POST-NOTRON": ""},
      lambda { |response, service_id| check_response_succeded(response, service_id) }
    )
  end

  it "Throw nodetron does not throw error when no headers are passed" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "nodetron",
      {},
      lambda { |response, service_id| check_response_succeded(response, service_id) }
    )
  end

  ## END NODETRON SECTION

  ## START JAVATRON SECTION

  it "Throw javatron throws error (targeted behavior)" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {"X-DEMO-THROW-POST-javatron": ""},
      lambda { |response, service_id| check_response_failed(response, service_id) }
    )
  end

  it "Throw javatron throws error (general behavior)" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {"X-DEMO-THROW-PRE": ""},
      lambda { |response, service_id| check_response_failed(response, service_id) }
    )
  end

  it "Throw javatron does not throw error when app id does not match" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {"X-DEMO-THROW-POST-NOTRON": ""},
      lambda { |response, service_id| check_response_succeded(response, service_id) }
    )
  end

  it "Throw javatron does not throw error when no headers are passed" do
    UserAcceptanceTests::Assertions::ServiceBehaviorResponse.new(@deployment_manager.context).execute(
      "api/inventory",
      "javatron",
      {},
      lambda { |response, service_id| check_response_succeded(response, service_id) }
    )
  end

  ## END JAVATRON SECTION
  # END THROW SECTION
end

def check_response_failed(response, service_id)
  if response.code.to_i >= 200 && response.code.to_i < 300
    raise "Service #{service_id} returned #{response.code} but should have returned an HTTP error"
  end
end

def check_response_succeded(response, service_id)
  if response.code.to_i <= 200 && response.code.to_i >= 300
    raise "Service #{service_id} returned #{response.code} but should have returned an HTTP error"
  end
end

def check_min_response_time(response, service_id, start_time, min_duration_ms)
  current_time = Time.now()
  duration = current_time - start_time
  duration_ms = duration.to_f * 1000
  if duration_ms < min_duration_ms
    raise "Service #{service_id} did not compute for at least #{min_duration_ms}ms. Actual: #{duration_ms}ms"
  end
end

def check_max_response_time(response, service_id, start_time, max_duration_ms)
  current_time = Time.now()
  duration = current_time - start_time
  duration_ms = duration.to_f * 1000
  if duration_ms > max_duration_ms
    raise "Service #{service_id} did not compute for at most #{max_duration_ms}ms. Actual: #{duration_ms}ms"
  end
end
