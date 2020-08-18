module Common
  module Install
    module Definitions
      class InstallDefinition

        def initialize(provisioned_resource,
                      erb_input_path,
                      yaml_output_path,
                      roles_path,
                      action_vars_lambda = nil,
                      output_params = nil)

          @provisioned_resource = provisioned_resource
          @erb_input_path = erb_input_path
          @yaml_output_path = yaml_output_path
          @roles_path = roles_path
          @action_vars_lambda = action_vars_lambda || lambda { return {} }
          @output_params = output_params
        end

        def get_provisioned_resource()
          return @provisioned_resource
        end

        def get_erb_input_path()
          return @erb_input_path
        end

        def get_yaml_output_path()
          return @yaml_output_path
        end

        def get_roles_path()
          return @roles_path
        end

        def get_action_vars()
          return @action_vars_lambda.call()
        end

        def get_output_params()
          return @output_params
        end

      end
    end
  end
end