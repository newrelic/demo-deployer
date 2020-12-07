require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"

require "./src/infrastructure/definitions/aws/resource_factory"
require "./tests/context_builder"

describe "Infrastructure::Definitions::Aws::ResourceFactory" do
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:parser) { m = mock(); m.stubs(:execute).returns({}); m }
  let(:config_ec2_resource) { JSON.parse({"id": "host1", "provider": "aws", "type": "ec2", "size": "t2.medium"}.to_json) }
  let(:windows_resource) { JSON.parse({"id": "host1", "provider": "aws", "type": "ec2", "size": "t2.medium", "is_windows": true}.to_json) }
  let(:config_elb_resource) { JSON.parse({"id": "webportalelb", "provider": "aws", "type": "elb", "listeners": ["webportal"]}.to_json) }

  let(:user_config_provider) { context.get_user_config_provider() }
  let(:tag_provider) { m = mock(); m.stubs(:get_resource_tags).returns({}); m }
  let(:resource_factory) { Infrastructure::Definitions::Aws::ResourceFactory.new(user_config_provider, tag_provider, "deployment_name") }

  it "should return valid resource factory" do
    resource_factory.wont_be_nil
  end

  it "should return ec2 resource" do
    resource = resource_factory.create(config_ec2_resource)
    resource.wont_be_nil
  end

  it "should return elb resource" do
    resource = resource_factory.create(config_elb_resource)
    resource.wont_be_nil
  end

  it "should return windows instance" do
    resource = resource_factory.create(windows_resource)
    resource.wont_be_nil
    resource.is_windows?().must_equal(true)
  end

  it "should NOT return windows instance" do
    resource = resource_factory.create(config_ec2_resource)
    resource.wont_be_nil
    resource.is_windows?().must_equal(false)
  end
end