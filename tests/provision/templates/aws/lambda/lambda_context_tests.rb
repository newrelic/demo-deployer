require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder.rb"
require "./src/infrastructure/definitions/aws/lambda_resource"
require "./src/provision/templates/aws/lambda/lambda_template_context"

describe "Provision::Aws::Lambda::LambdaTemplateContext" do
  let(:lambda1) { "lambda1" }
  let(:context) { Tests::ContextBuilder.new()
    .user_config().with_aws()
    .infrastructure().lambda(lambda1)
    .services().service("app1", 5000, "/mypath", "/deploy")
    .tags().with("Name", "instanceName")
    .build() }
  let(:output_dir_path) { "/tmp/test_create" }
  let(:template_root_path) { "./src/provision/templates/aws/lambda"}

  before do
    FileUtils.stubs(:mkdir_p)
    File.stubs(:open)
  end

  it "should create composer" do
    when_template_context().wont_be_nil()
  end

  it "should execute with no errors" do
    return_value = when_template_context().get_template_binding()
    return_value.wont_be_nil()
    return_value.must_be_instance_of(Binding)
  end

  it "should execute and return a binding object with non-empty array under the 'lambda' key" do
    return_value = when_template_context().get_template_binding()
    return_value.local_variable_get("lambda_function").wont_be_empty()
  end
  
  def get_resource()
    resource = context.get_infrastructure_provider().get_by_id(lambda1)
    return resource
  end

  def when_template_context()
    resource = get_resource()
    return Provision::Templates::Aws::Lambda::LambdaTemplateContext.new(output_dir_path, template_root_path, context, resource)
  end
end
