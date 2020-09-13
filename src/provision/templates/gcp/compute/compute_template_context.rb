require "./src/provision/templates/template_context.rb"
require "./src/provision/templates/gcp/vnet/vnet_template_context.rb"

module Provision
  module Templates
    module Gcp
      module Compute

        class ComputeTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/compute.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()

            Provision::Templates::Gcp::Vnet::VnetTemplateContext.set_template_context(template_binding, get_context(), get_resource())

            compute_template_context = {}
            compute_template_context[:remote_user] = get_resource().get_user_name()
            compute_template_context[:artifact_file_path] = get_output_file_path()

            parse_infrastructure_resource(compute_template_context)
            parse_deployment(compute_template_context)
            parse_services_provider(compute_template_context)

            template_binding.local_variable_set("compute", compute_template_context)

            return template_binding
          end

          private
          def parse_infrastructure_resource(compute_template_context)
            compute_template_context[:instance_size] = get_resource().get_size()
            compute_template_context[:resource_id] = get_resource().get_id()
            compute_template_context[:tags] = get_resource_tags().to_json()
            compute_template_context[:source_image] = get_resource().get_source_image()
          end

          def get_resource_tags()
            service_ids = get_services_provider().aggregate_value(get_resource_id()) { |service| service.get_id() }
            tags = get_resource().get_tags()
            tags[:Name] = get_resource_name()
            tags[:Services] = service_ids.join('-')
            return tags
          end

          def parse_deployment(compute_template_context)
            resource_name = get_resource_name()
            compute_template_context[:resource_name] = resource_name
            compute_template_context[:disk_name] = "#{resource_name}-disk"
            compute_template_context[:address_name] = "#{resource_name}-address"
          end

          def parse_services_provider(template_context)
            service_ports = get_services_provider().aggregate_value(get_resource_id()) { |service| service.get_port() }
            valid_ports = []
            service_ports.each do |port|
              if port != 9999
                valid_ports.push(port)
              end
            end
            template_context[:ports] = valid_ports
          end

        end
      end
    end
  end
end