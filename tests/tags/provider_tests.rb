require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/tags/provider"

describe "Tags::Provider" do
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:deployment_name) { "user-deploy" }
  let(:global_tags) { {"tag:name_"=> "tag:value"} }
  let(:services_tags) { {} }
  let(:resources_tags) { {} }
  let(:provider) { Tags::Provider.new(context, global_tags, services_tags, resources_tags) }

  it "should create provider" do
    provider.wont_be_nil
  end

  it "should return tags defined with deployment name" do
    all_tags = provider.get_resource_tags("anything")
    all_tags.must_include("dxDeploymentName")
  end

  it "should not overwrite system-added deployment name if manually configured" do
    given_resource_tags("key1", {"dxDeploymentName"=> "testingdeployname"})
    all_tags = provider.get_resource_tags("key1")
    refute_match /testingdeployname/, all_tags.to_s
  end

  it "should allow a resource tag to overwrite a global tag" do
    given_resource_tags("key1", {"tag:name_"=> "testingoverwrite"})
    all_tags = provider.get_resource_tags("key1")
    assert_match /testingoverwrite/, all_tags.to_s
  end

  def given_resource_tags(key, tags)
    resources_tags[key] = tags
  end


  it "should not overwrite system-added deployment name if manually configured" do
    given_service_tags("key1", {"dxDeploymentName"=> "testingdeployname"})
    all_tags = provider.get_service_tags("key1")
    refute_match /testingdeployname/, all_tags.to_s
  end

  it "should allow a service tag to overwrite a global tag" do
    given_service_tags("key1", {"tag:name_"=> "testingoverwrite"})
    all_tags = provider.get_service_tags("key1")
    assert_match /testingoverwrite/, all_tags.to_s
  end

  def given_service_tags(key, tags)
    services_tags[key] = tags
  end

end