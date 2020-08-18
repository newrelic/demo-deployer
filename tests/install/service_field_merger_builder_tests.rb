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
    given_provisioned_service("host1", "1.2.3.4")
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

  def given_service(service_id, destinations, port = 5000)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations)
  end

  def given_ec2_resource(id)
    context_builder.infrastructure().ec2(id, "t2.micro")
  end  

  def given_provisioned_service(id, ip)
    context_builder.provision().service_host(id, ip)
  end
  
  def given_provisioned_service_url(id, url)
    context_builder.provision().service_endpoint(id, url)
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

end
