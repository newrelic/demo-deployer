require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Aws
      module Elb
        class ElbTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/elb.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            template_context = {}

            parse_credential(template_context, get_resource().get_credential())
            template_context[:remote_user] = get_resource().get_user_name()
            template_context[:artifact_file_path] = get_output_file_path()

            parse_infrastructure_resource(template_context)
            parse_deployment(template_context)
            parse_app_config_provider(template_context)

            template_binding.local_variable_set("elb", template_context)

            return template_binding
          end

          def parse_credential(template_context, credential)
            template_context[:aws_access_key] = credential.get_access_key()
            template_context[:aws_secret_key] = credential.get_secret_key()
            template_context[:aws_region] = credential.get_region()
          end

          def parse_infrastructure_resource(template_context)
            template_context[:resource_id] = get_resource_id()
          end

          def parse_deployment(template_context)
            deployment_name = get_deployment_name()
            resource_id = get_resource_id()
            listeners = get_resource().get_listeners()
            listener_resources = get_listener_resources(deployment_name, listeners)
            template_context[:deployment_name] = deployment_name
            template_context[:resource_port] = listener_resources["port"]
            template_context[:resource_name] = get_resource_name()
            template_context[:listener_resource_names] = listener_resources["listener_resource_names"]
            template_context[:tags] = get_resource_tags().to_json
          end

          def parse_app_config_provider(template_context)
            template_context[:elb_port] = get_app_config_provider().get_aws_elb_port()
          end

          private
          def get_listener_resources(deployment_name, listeners)
            file = {}
            all_resource_names = []
            listeners.each do |listener|
              resource_names = []
              service = get_services_provider().get_by_id(listener)
              file["port"] = service.get_port()
              destinations = service.get_destinations()
              destinations.each do |resource_id|
                service_ids = get_services_provider().aggregate_value(resource_id) { |service| service.get_id() }
                resource_names.push("#{deployment_name}-#{resource_id}")
              end
              all_resource_names.push(resource_names)
            end
            file["listener_resource_names"] = all_resource_names.flatten
            return file
          end

          def get_resource_tags()
            tags = get_resource().get_tags()
            resource_name = get_resource_name()
            tags[:Name] = resource_name
            return tags
          end

        end
      end
    end
  end
end