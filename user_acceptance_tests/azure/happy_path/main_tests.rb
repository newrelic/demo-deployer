require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "minitest/hooks"

require "./user_acceptance_tests/assertions/service_relationship"
require "./user_acceptance_tests/file_finder"
require "./user_acceptance_tests/deployment_manager"

describe "UserAcceptanceTests::Azure::HappyPath" do
  include Minitest::Hooks

  before(:all) do
    @deployment_manager = DeploymentManager.new("azure.uat.json", __dir__)
    @deployment_manager.deploy()
  end

  after(:all) do
    @deployment_manager.teardown()
  end

  after do
    @deployment_manager.after_each()
  end

  it "should provision successfully" do
    UserAcceptanceTests::Assertions::ServiceRelationship.new(@deployment_manager.context).execute(
      ["inventory","inventory/5","validateMessage?message=uat"],
      ["uat1", "uat2", "uat3", "uat4"]
    )
  end
end