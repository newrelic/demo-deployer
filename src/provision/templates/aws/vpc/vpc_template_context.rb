require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Aws
      module Vpc
        class VpcTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, deployment_name, resource)
            super(output_file_path, template_file_path, deployment_name, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/vpc/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/vpc.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            template_context = {}
            parse_credential(template_context, get_resource().get_credential())
            template_binding.local_variable_set("vpc", template_context)
            return template_binding
          end

          private
          def parse_credential(template_context, credential)
            template_context[:aws_access_key] = credential.get_access_key()
            template_context[:aws_secret_key] = credential.get_secret_key()
            template_context[:region] = credential.get_region()
            availability_zone = credential.get_availability_zone()
            unless availability_zone.nil?
              template_context[:availability_zone] = availability_zone
            end
          end

        end
      end
    end
  end
end