require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder.rb"
require "./src/infrastructure/definitions/aws/ec2_resource"
require "./src/provision/templates/aws/vpc/vpc_template_context"

describe "Provision::Templates::Aws::Vpc" do
  let(:host1) { "host1" }
  let(:context) { Tests::ContextBuilder.new()
    .user_config().with_aws()
    .infrastructure().ec2("host1")
    .tags().with("Name", "instanceName")
    .build() }
  let(:output_dir_path) { "/tmp/test_create" }
  let(:template_root_path) { "./src/provision/templates/aws"}

  before do
    FileUtils.stubs(:mkdir_p)
    File.stubs(:open)
    FileUtils.stubs(:read)
  end

  it "should create composer" do
    when_template_context().wont_be_nil()
  end

  it "should execute with no errors" do
    when_template_context().get_template_binding()
  end

  it "should execute and return a binding object with non-empty array under the 'vpc' key" do
    return_value = when_template_context().get_template_binding()
    return_value.local_variable_get("vpc").wont_be_empty
  end

  it "should execute and return 3 values" do
    return_value= when_template_context().get_template_binding()
    return_value.local_variable_get("vpc").count.must_equal(3)
  end

  def get_resource()
    resource = context.get_infrastructure_provider().get_by_id(host1)
    return resource
  end

  def when_template_context()
    resource = get_resource()
    return Provision::Templates::Aws::Vpc::VpcTemplateContext.new(output_dir_path, template_root_path, context, resource)
  end  

end