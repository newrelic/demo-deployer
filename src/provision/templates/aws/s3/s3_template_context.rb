require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Aws
      module S3
        class S3TemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/s3.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            template_context = {}

            parse_credential(template_context, get_resource().get_credential())
            template_context[:artifact_file_path] = get_output_file_path()
            template_context[:resource_name] = get_resource_name()
            parse_infrastructure_resource(template_context)

            template_binding.local_variable_set("s3", template_context)
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
            template_context[:tags] = get_resource_tags().to_json()
          end

          def get_resource_tags()
            tags = get_resource().get_tags()
            tags[:Name] = get_resource_name()
            return tags
          end

        end
      end
    end
  end
end