require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder"
require "./src/install/service_field_merger_builder"

describe "Install::ServiceFieldMergerBuilder" do

  let(:context_builder){ Tests::ContextBuilder.new() }

  it "should build service field merger with no services and resources" do
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
  end

  it "should build service field merger with service and provisioned resource" do
    given_ec2_resource("host1")
    given_provisioned_service_ip("host1", "1.2.3.4")
    given_service("app1", ["host1"], 5001)
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[service:app1]").must_equal("http://1.2.3.4:5001")
    merger.merge("[service:app1:port]").must_equal("5001")
    merger.merge("[service:app1:url]").must_equal("http://1.2.3.4:5001")
  end
  
  it "should build service field merger with service and provisioned resource url" do
    given_ec2_resource("host1")
    given_provisioned_service_url("host1", "http://myelb.somewhere.com/api")
    given_service("app1", ["host1"], 5001)
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[service:app1]").must_equal("http://myelb.somewhere.com/api")
    merger.merge("[service:app1:url]").must_equal("http://myelb.somewhere.com/api")
  end

  it "should build service field merger with service and display_name" do
    given_ec2_resource("host1")
    given_provisioned_service_url("host1", "http://myelb.somewhere.com/api")
    given_service("app1", ["host1"], 5001, "Service 1")
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[service:app1:display_name]").must_equal("Service 1")
  end

  it "should build service field merger with service and defailt display_name" do
    given_ec2_resource("host1")
    given_provisioned_service_url("host1", "http://myelb.somewhere.com/api")
    given_service("app1", ["host1"], 5001)
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[service:app1:display_name]").must_equal("app1")
  end

  it "should prefix with http when unspecified for provisioned resource url" do
    given_ec2_resource("host1")
    given_provisioned_service_url("host1", "myelb.somewhere.com/api")
    given_service("app1", ["host1"], 5001)
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[service:app1]").must_equal("http://myelb.somewhere.com/api")
    merger.merge("[service:app1:url]").must_equal("http://myelb.somewhere.com/api")
  end
   
  it "should build service field merger WITHOUT user credentials" do
    merger = given_builder()
      .build()
    merger.wont_be_nil()
    merger.merge("[credential:newrelic:license_key]").must_equal("[credential:newrelic:license_key]")
  end

  it "should build service field merger with user credentials" do
    given_new_relic_credential("test_license_key") 
    merger = given_builder()
      .with_user_credentials(context())
      .build()
    merger.wont_be_nil()
    merger.merge("[credential:newrelic:license_key]").must_equal("test_license_key")
  end
   
  it "should build service field merger with app_config" do
    given_app_config_url("us", "test_url", "test.com")
    merger = given_builder()
      .with_app_config(context())
      .build()
    merger.wont_be_nil()
    merger.merge("[app_config:newrelic:test_url]").must_equal("test.com") 
  end

  it "should build resource field merger and provisioned resource" do
    given_ec2_resource("host1", "MyHost1")
    given_provisioned_service("host1", {"ip"=>"1.2.3.4", "private_dns_name"=>"my.private.host.com", "instance_id"=>"i-abc123"})
    given_service("app1", ["host1"], 5001)
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[resource:host1:display_name]").must_equal("MyHost1")
    merger.merge("[resource:host1:ip]").must_equal("1.2.3.4")
    merger.merge("[resource:host1:private_dns_name]").must_equal("my.private.host.com")
    merger.merge("[resource:host1:instance_id]").must_equal("i-abc123")
  end

  it "should build resource field merger and provisioned resource with default display_name" do
    given_ec2_resource("host1")
    given_provisioned_service_ip("host1", "1.2.3.4")
    given_service("app1", ["host1"], 5001)
    merger = given_builder()
      .with_services(services(), provisioned_resources())
      .build()
    merger.wont_be_nil()
    merger.merge("[resource:host1:display_name]").must_equal("host1")
  end

  def given_service(service_id, destinations, port = 5000, display_name = nil)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations, display_name)
  end

  def given_ec2_resource(id, display_name = nil)
    context_builder.infrastructure().ec2(id, "t2.micro", display_name)
  end

  def given_provisioned_service(id, params)
    context_builder.provision().service(id, params)
  end

  def given_provisioned_service_ip(id, ip)
    context_builder.provision().service(id, {"ip"=>ip})
  end

  def given_provisioned_service_url(id, url)
    context_builder.provision().service(id, {"url"=>url})
  end

  def given_new_relic_credential(licenseKey) 
    context_builder.user_config().with_new_relic(licenseKey)
  end

  def given_app_config_url(region, name, url)
    context_builder.app_config().with("newRelicUrls", { region => { name => url }})
  end

  def given_builder()
    return @builder ||= create_builder()
  end

  def create_builder()
    @context = context_builder.build()
    return Install::ServiceFieldMergerBuilder.new()
  end

  def services()
    return @context.get_services_provider().get_all()
  end

  def provisioned_resources()
    return @context.get_provision_provider().get_all()
  end

  def context()
    return @context
  end
end
