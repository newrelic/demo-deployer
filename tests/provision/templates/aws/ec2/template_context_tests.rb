require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder.rb"
require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/provision/templates/aws/ec2/ec2_template_context"

describe "Provision::Aws::Ec2::Ec2TemplateContext" do
  let(:host1) { "host1" }
  let(:context_builder) { Tests::ContextBuilder.new().user_config().with_aws() }
  let(:output_dir_path) { "/tmp/test_create" }
  let(:template_root_path) { "./src/provision/templates/aws/ec2"}

  before do
    FileUtils.stubs(:mkdir_p)
    File.stubs(:open)
  end

  it "should create composer" do
    given_ec2_resource(host1)
    when_template_context(host1).wont_be_nil()
  end

  it "should execute with no errors" do
    given_ec2_resource(host1)
    return_value = when_template_context(host1).get_template_binding()
    return_value.wont_be_nil()
    return_value.must_be_instance_of(Binding)
  end

  it "should execute and return a binding object with non-empty array under the 'ec2' key" do
    given_ec2_resource(host1)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("ec2").wont_be_empty()
  end

  it "should get service port" do
    given_ec2_resource(host1)
    given_service("app1", [host1], 5000)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("ec2").wont_be_empty()
    ec2 = return_value.local_variable_get("ec2")
    ec2[:ports].must_equal([5000])
  end

  it "should not get restricted 9999 service port" do
    given_ec2_resource(host1)
    given_service("app1", [host1], 9999)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("ec2").wont_be_empty()
    ec2 = return_value.local_variable_get("ec2")
    ec2[:ports].must_be_empty()
  end

  def given_ec2_resource(id)
    context_builder.infrastructure().ec2(id)
  end

  def given_service(service_id, destinations, port = 5000)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations)
  end

  def when_template_context(id)
    context = context_builder.build()
    resource = context.get_infrastructure_provider().get_by_id(id)
    return Provision::Templates::Aws::Ec2::Ec2TemplateContext.new(output_dir_path, template_root_path, context, resource)
  end
end
