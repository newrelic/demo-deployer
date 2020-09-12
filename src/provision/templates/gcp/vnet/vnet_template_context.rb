require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Gcp
      module Vnet
        class VnetTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, deployment_name, services_provider, resource)
            super(output_file_path, template_file_path, deployment_name, resource)
            @services_provider = services_provider
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/vnet/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/vnet.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            Provision::Templates::Gcp::Vnet::VnetTemplateContext.set_template_context(template_binding, get_deployment_name(), @services_provider, get_resource())
            return template_binding
          end

          def self.set_template_context(template_binding, deployment_name, services_provider, resource)
            gcp_template_context = {}
            parse_credential(gcp_template_context, resource)
            parse_resource_group(gcp_template_context, deployment_name)
            parse_services_provider(gcp_template_context, services_provider, resource)
            template_binding.local_variable_set("gcp", gcp_template_context)
          end

          private
          def self.parse_credential(template_context, resource)
            credential = resource.get_credential()
            template_context[:auth_kind] = credential.get_auth_kind()
            template_context[:project] = credential.get_project()
            template_context[:service_account_file] = credential.get_service_account_file()
            template_context[:region] = credential.get_region()
          end

          def self.parse_resource_group(template_context, deployment_name)
            template_context[:resource_group] = "#{deployment_name}"
            template_context[:vnet_name] = "#{deployment_name}-vnet"
          end

          def self.parse_services_provider(gcp_template_context, services_provider, resource)
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
            gcp_template_context[:ports] = ports
            gcp_template_context[:range_ports] = ports.join("-")
          end

        end
      end
    end
  end
end