require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./user_acceptance_tests/deployment_manager"

describe "UserAcceptanceTests::Aws::Empty" do
  it "should provision empty deploy config" do
    deployment_manager = DeploymentManager.new("empty.uat.json", __dir__)
    deployment_manager.deploy()
    deployment_manager.teardown()
    deployment_manager.after_each()
  end
end