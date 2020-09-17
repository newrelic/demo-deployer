require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Aws
      module Ec2
        class Ec2TemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/ec2.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            template_context = {}

            parse_credential(template_context, get_resource().get_credential())
            template_context[:remote_user] = get_resource().get_user_name()
            template_context[:ami_name] = get_resource().get_ami_name()
            template_context[:artifact_file_path] = get_output_file_path()
            template_context[:resource_name] = get_resource_name()
            template_context[:cpu_credit_specification] = get_resource().get_cpu_credit_specification()
            parse_infrastructure_resource(template_context)
            parse_services_provider(template_context)

            template_binding.local_variable_set("ec2", template_context)
            return template_binding
          end

          private
          def parse_credential(template_context, credential)
            template_context[:aws_access_key] = credential.get_api_key()
            template_context[:aws_secret_key] = credential.get_secret_key()
            template_context[:secret_key_name] = credential.get_secret_key_name()
            template_context[:region] = credential.get_region()
          end

          def parse_infrastructure_resource(template_context)
            template_context[:instance_size] = get_resource().get_size()
            template_context[:resource_id] = get_resource().get_id()
            template_context[:tags] = get_resource_tags().to_json()
          end

          def get_resource_tags()
            service_ids = get_services_provider().aggregate_value(get_resource_id()) { |service| service.get_id() }
            tags = get_resource().get_tags()
            tags[:Name] = get_resource_name()
            tags[:Services] = service_ids.join('-')
            return tags
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