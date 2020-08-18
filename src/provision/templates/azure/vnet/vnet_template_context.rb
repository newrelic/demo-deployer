require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Azure
      module Vnet
        class VnetTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/vnet/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/vnet.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            Provision::Templates::Azure::Vnet::VnetTemplateContext.set_template_context(template_binding, get_context(), get_resource())
            return template_binding
          end

          def self.set_template_context(template_binding, context, resource)
            azure_template_context = {}
            parse_credential(azure_template_context, resource)
            parse_resource_group(azure_template_context, context, resource)
            parse_services_provider(azure_template_context, context, resource)
            template_binding.local_variable_set("azure", azure_template_context)
          end

          private
          def self.parse_credential(template_context, resource)
            credential = resource.get_credential()
            template_context[:client_id] = credential.get_client_id()
            template_context[:tenant] = credential.get_tenant()
            template_context[:subscription_id] = credential.get_subscription_id()
            template_context[:secret] = credential.get_secret()
            template_context[:region] = credential.get_region()
            template_context[:ssh_public_key] = credential.get_ssh_public_key()
          end

          def self.parse_resource_group(template_context, context, resource)
            deployment_name = context.get_command_line_provider().get_deployment_name()
            resource_id = resource.get_id()
            template_context[:resource_group] = "#{deployment_name}"
            template_context[:vnet_name] = "#{deployment_name}-vnet"
            template_context[:subnet_name] = "#{deployment_name}-subnet"
            template_context[:sg_name] = "#{deployment_name}-#{resource_id}-sg"
          end

          def self.parse_services_provider(azure_template_context, context, resource)
            services_provider = context.get_services_provider()
            ports = []
            min_port = -1
            max_port = -1
            resource_id = resource.get_id()
            services_provider.get_services().each do |service| 
              resource_is_included = service.get_destinations().any? { |destination| destination == resource_id }
              if resource_is_included
                port = service.get_port()
                if port != 9999
                  if min_port == -1 && max_port == -1
                    min_port = port
                    max_port = port
                  else
                    if port < min_port
                      min_port = port
                    end
                    if port > max_port
                      max_port = port
                    end
                  end
                end
              end
            end
            if min_port != -1 && max_port != -1
              if min_port != max_port
                ports.push(min_port)
                ports.push(max_port)
              else
                ports.push(min_port)
              end
            end
            azure_template_context[:range_ports] = ports.join("-")
          end

        end
      end
    end
  end
end