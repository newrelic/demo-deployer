require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"
require "json"

require "./src/infrastructure/provider"
require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/infrastructure/definitions/aws/aws_resource"

describe "Infrastructure::Provider" do

  let(:resource_factory) { m = mock(); m.stubs(:create).returns("anything..."); m }
  let(:user_config_provider) { m = mock(); m }
  let(:tag_provider) { m = mock(); m }
  let(:empty_json_resource) { [] }
  let(:single_json_resource) { JSON.parse([{"id":"host1", "provider":"aws", "type":"ec2", "size":"t2.micro", "tags":{}}].to_json) }
  let(:double_json_resource) { JSON.parse([
    {"id":"host1", "provider":"aws", "type":"ec2", "size":"t2.micro"},
    {"id":"host1", "provider":"aws", "type":"ec2", "size":"t2.micro"}
  ].to_json) }

  let(:credential) { mock() }

  it "should not create any resource when empty" do
      provider = given_provider(empty_json_resource)
      provider.get_all().length.must_equal(0)
    end

    it "should create single resource" do
      provider = given_provider(single_json_resource)
      provider.get_all().length.must_equal(1)
    end

    it "should create multiple resources" do
      provider = given_provider(double_json_resource)
      provider.get_all().length.must_equal(2)
    end

    it "should call resource factory once for building" do
      resource_factory.expects(:create).once
      provider = given_provider(single_json_resource)
      provider.get_all()
    end

    it "should call resource factory multiple times for each building" do
      resource_factory.expects(:create).twice
      provider = given_provider(double_json_resource)
      provider.get_all()
    end

    it "should return a map of EC2 groups" do
      provider = given_provider(single_json_resource)
      provider.stubs(:get_all).returns([given_ec2_resource("1"), given_ec2_resource("2")])
      group = provider.partition_by_provision_group()
      group.size.must_equal(1)
    end


    it "should return resources in group order" do
      provider = given_provider(single_json_resource)

      group1 = given_aws_resource("2", provision_group=1)
      group2 = given_aws_resource("1", provision_group=2)
      provider.stubs(:get_all).returns([group2, group1])

      group = provider.partition_by_provision_group()
      group[0].must_include(group1)
      group[1].must_include(group2)
    end

    it "should return a map of ELB groups" do
      provider = given_provider(single_json_resource)
      provider.stubs(:get_all).returns([given_ec2_resource("1"), given_ec2_resource("2"), given_elb_resource("3", ["fulfillment"]), given_elb_resource("4", ["webportal"])])
      group = provider.partition_by_provision_group()
      group.size.must_equal(2)
    end

    def given_aws_resource(id, provision_group, type='thing', credential="")
      return Infrastructure::Definitions::Aws::AwsResource.new(id, type, credential, provision_group)
    end

    def given_provider(json)
      return Infrastructure::Provider.new(json, user_config_provider, tag_provider, resource_factory)
    end

    def given_elb_resource(id, listeners, provider="aws", type="elb", user_name="username")
      return Infrastructure::Definitions::Aws::ElbResource.new(id, credential, listeners, user_name, [])
    end

    def given_ec2_resource(id, provider="aws", type="ec2", size ="t2.micro", user_name="user_name")
      return Infrastructure::Definitions::Aws::Ec2Resource.new(id, credential, size, user_name, [])
    end

end