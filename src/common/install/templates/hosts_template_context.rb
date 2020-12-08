module Common
  module Install
    module Templates
      class HostsTemplateContext

        def initialize(action_name, erb_input_path, yaml_output_path, provisioned_resource)
          @action_name = action_name
          @erb_input_path = erb_input_path
          @yaml_output_path = yaml_output_path
          @provisioned_resource = provisioned_resource
        end

        def get_template_input_file_path()
          return "#{@erb_input_path}/hosts_template.erb"
        end

        def get_template_output_file_path()
          return "#{@yaml_output_path}/hosts"
        end

        def get_id()
          unless @provisioned_resource.nil?
            return @provisioned_resource.get_id()
          end
          return ""
        end

        def host_exist?()
          if @provisioned_resource != nil && @provisioned_resource.get_ip() != nil
            return true
          else
            return false
          end
        end

        def get_template_binding()
          destination = {}

          destination[:action_name] = @action_name
          destination_ip = "localhost"
          destination_remote_user = ""

          unless @provisioned_resource.nil?
            destination_remote_user = @provisioned_resource.get_user_name()
            destination_ip = @provisioned_resource.get_ip()
          end

          destination[:remote_user] = destination_remote_user
          destination[:ip] = destination_ip
          if ['localhost','127.0.0.1', '0.0.0.0'].include?(destination_ip)
            destination[:force_local_connection] = 'ansible_connection=local'
          end
          keyvalues = {}
          if @provisioned_resource.get_resource().is_windows?()
            keyvalues["ansible_password"] = @provisioned_resource.get_param("win_password")
            keyvalues["ansible_port"] = "5986"
            keyvalues["ansible_connection"] = "winrm"
            keyvalues["ansible_winrm_server_cert_validation"] = "ignore"
          end
          destination[:keyvalues] = keyvalues
          template_binding = Kernel.binding()
          template_binding.local_variable_set('destination', destination)

          return template_binding
        end

      end
    end
  end
end