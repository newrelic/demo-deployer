require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./tests/context_builder.rb"
require "./src/infrastructure/definitions/azure/vm_resource"
require "./src/provision/templates/azure/vnet/vnet_template_context"

describe "Provision::Azure::Vnet::VnetTemplateContext" do
  let(:host1) { "host1" }
  let(:host2) { "host2" }
  let(:host3) { "host3" }
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

  it "should execute and return a binding object with non-empty array under the 'azure' key" do
    given_vm_resource(host1)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("azure").wont_be_empty()
  end

  it "should return single service port" do
    given_vm_resource(host1)    
    given_service("app1", [host1], 5000)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("azure").wont_be_empty()
    azure = return_value.local_variable_get("azure")
    azure[:range_ports].must_equal("5000")
  end

  it "should return all ports for multiple service on same host" do
    given_vm_resource(host1)    
    given_service("app1", [host1], 5000)
    given_service("app2", [host1], 5002)
    given_service("app4", [host1], 5004)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("azure").wont_be_empty()
    azure = return_value.local_variable_get("azure")
    azure[:range_ports].must_equal("5000-5004")
  end
  
  it "should not open special 9999 port" do
    given_vm_resource(host1)    
    given_service("app1", [host1], 5000)
    given_service("app2", [host1], 9999)
    given_service("app4", [host1], 5004)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("azure").wont_be_empty()
    azure = return_value.local_variable_get("azure")
    azure[:range_ports].must_equal("5000-5004")
  end
  
  it "should return ports for service on their host" do
    given_vm_resource(host1)
    given_vm_resource(host2)
    given_vm_resource(host3)
    given_service("a1", [host1], 5000)
    given_service("z3", [host2], 5001)
    given_service("a2", [host1], 5002)
    given_service("z5", [host2], 5003)
    given_service("a4", [host1], 5004)
    given_service("z7", [host2], 5005)
    given_service("x1", [host3], 8080)
    return_value = when_template_context(host1).get_template_binding()
    return_value.local_variable_get("azure")[:range_ports].must_equal("5000-5004")

    return_value = when_template_context(host2).get_template_binding()
    return_value.local_variable_get("azure")[:range_ports].must_equal("5001-5005")
    
    return_value = when_template_context(host3).get_template_binding()
    return_value.local_variable_get("azure")[:range_ports].must_equal("8080")
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
    return Provision::Templates::Azure::Vnet::VnetTemplateContext.new(output_dir_path, template_root_path, context, resource)
  end
end
