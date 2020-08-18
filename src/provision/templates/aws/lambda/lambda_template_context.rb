require "./src/provision/templates/template_context.rb"

module Provision
  module Templates
    module Aws
      module Lambda
        class LambdaTemplateContext < TemplateContext

          def initialize(output_file_path, template_file_path, context, resource)
            super(output_file_path, template_file_path, context, resource)
          end

          def get_absolute_path()
            return File.dirname(__FILE__)
          end

          def get_template_input_file_path()
            return "#{get_template_file_path()}/template.erb"
          end

          def get_zip_file_path()
            return "#{get_absolute_path()}/lambda.zip"
          end

          def get_swagger_file_path()
            return "#{get_absolute_path()}/swagger_template.yml.j2"
          end

          def get_template_output_file_path()
            return "#{get_output_file_path()}/lambda.yml"
          end

          def get_template_binding()
            template_binding = Kernel.binding()
            template_context = {}

            parse_credential(template_context, get_resource().get_credential())
            template_context[:output_file_path] = get_output_file_path()
            template_context[:artifact_file_path] = get_output_file_path()
            template_context[:zip_file_path] = get_zip_file_path()
            template_context[:swagger_file_path] = get_swagger_file_path()
            template_context[:remote_user] = get_resource().get_user_name()
            template_context[:api_gateway_api_id] = get_resource().get_api_id() || ""

            parse_infrastructure_resource(template_context)
            create_names(template_context)
            template_binding.local_variable_set("lambda_function", template_context)

            return template_binding
          end

          def parse_credential(template_context, credential)
            template_context[:aws_access_key] = credential.get_api_key()
            template_context[:aws_secret_key] = credential.get_secret_key()
            template_context[:aws_region] = credential.get_region()
          end

          def parse_infrastructure_resource(template_context)
            template_context[:resource_id] = get_resource_id()
            template_context[:resource_name] = get_resource_name()
            template_context[:tags] = get_resource_tags().to_json
          end

          def get_lambda_function_name()
            return "#{get_deployment_name()}-#{get_resource_id()}-api"
          end

          def create_names(template_context)
            deployment_name = get_deployment_name()
            resource_id = get_resource_id()
            template_context[:iam_role_name] = deployment_name+"-"+resource_id+"-iam-lambda-role"
            template_context[:iam_policy_name] = deployment_name+"-"+resource_id+"-iam-lambda-policy"
            template_context[:vpc_security_group_name] = deployment_name+"-"+resource_id+"-vpc-security-group"
            template_context[:lambda_function_name] = get_lambda_function_name()
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