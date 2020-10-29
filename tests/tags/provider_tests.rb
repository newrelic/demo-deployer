require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/tags/provider"

describe "Tags::Provider" do
  let(:context){ Tests::ContextBuilder.new().user_config().with_new_relic().build() }
  let(:deployment_name) { "user-deploy" }
  let(:global_tags) { {} }
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
    given_global_tag("tag:name_", "tag:value")
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

  it "should merge global fields" do
    given_global_tag("testtag", "[global:deployment_name]")
    global_tags = provider.get_global_tags()
    assert_match("user-deploy", global_tags.to_s())
  end

  it "should merge new relic credential fields" do
    given_global_tag("testLicense", "[credential:newrelic:license_key]")
    global_tags = provider.get_global_tags()
    assert_match("LICENSE_KEY", global_tags.to_s())
  end

  def given_service_tags(key, tags)
    services_tags[key] = tags
  end

  def given_global_tag(key, value)
    global_tags[key] = value
  end
end
