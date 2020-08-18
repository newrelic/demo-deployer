require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder.rb"
require "./src/infrastructure/definitions/azure/vm_resource"
require "./src/provision/templates/azure/vm/vm_template_context"

describe "Provision::Azure::Vm::VmTemplateContext" do
  let(:host1) { "host1" }
  let(:context_builder) { Tests::ContextBuilder.new().user_config().with_azure() }
  let(:output_dir_path) { "/tmp/test_create" }
  let(:template_root_path) { "./src/provision/templates/azure/vm"}

  before do
    FileUtils.stubs(:mkdir_p)
    File.stubs(:open)
  end

  it "should create composer" do
    given_vm_resource(host1)
    when_template_context(host1).wont_be_nil()
  end

  it "should execute with no errors" do
    given_vm_resource(host1)
    return_value = when_template_context(host1).get_template_binding()
    return_value.wont_be_nil()
    return_value.must_be_instance_of(Binding)
  end

  it "should execute and return a binding object with non-empty array under the 'vm' key" do
    given_vm_resource(host1)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("vm").wont_be_empty()
  end

  def given_vm_resource(id)
    context_builder.infrastructure().vm(id)
  end

  def given_service(service_id, destinations, port = 5000)
    local_source_path = "src/path"
    deploy_script_path = "deploy"
    context_builder.services().service(service_id, port, local_source_path, deploy_script_path, destinations)
  end

  def when_template_context(id)
    context = context_builder.build()
    resource = context.get_infrastructure_provider().get_by_id(id)
    return Provision::Templates::Azure::Vm::VmTemplateContext.new(output_dir_path, template_root_path, context, resource)
  end
end
