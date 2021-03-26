module Common
  module Install
    module Templates
      class ActionTemplateContext

        def initialize(action_name, erb_input_path, yaml_output_path, provisioned_resource, action_vars)
          @action_name = action_name
          @erb_input_path = erb_input_path
          @yaml_output_path = yaml_output_path
          @provisioned_resource = provisioned_resource
          @action_vars = action_vars
        end

        def get_template_input_file_path()
          return "#{@erb_input_path}/action_template.erb"
        end

        def get_template_output_file_path()
          return "#{@yaml_output_path}/#{@action_name}.yml"
        end

        def get_execution_path()
          return "#{@yaml_output_path}"
        end

        def get_template_binding()
          template_binding = Kernel.binding()
          template_binding.local_variable_set('action_name', @action_name)

          all_vars = {
            output_path: get_execution_path()
          }

          all_vars = all_vars.merge(@action_vars)

          unless @provisioned_resource.nil?
            params = @provisioned_resource.get_params().get_all()
            all_vars = all_vars.merge(params)
          end

          # windows password should not be passed as action param (not yaml encoded, and not needed)
          all_vars.delete('win_password')

          template_binding.local_variable_set('action_vars', all_vars)
          return template_binding
        end

      end
    end
  end
end