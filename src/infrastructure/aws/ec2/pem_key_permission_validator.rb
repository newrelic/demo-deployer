
module Infrastructure
  module Aws
    module Ec2
      class PemKeyPermissionValidator
        # regex to confirm the file permission is 400,500,600,700
        # which are all valid permissions for a AWS pem key
        PERMISSION_REGEX = /[4-7]00$/

        def initialize(context)
          @context = context
        end

        def execute()
          pem_key_path = get_pem_key_path()
          pem_key_persmissions = get_file_permission(pem_key_path)
          if pem_key_persmissions.nil? || !pem_key_persmissions.to_s.match(PERMISSION_REGEX)
            return "The pem key file '#{pem_key_path}' does not have the correct permissions.  To fix run 'chmod 400 #{pem_key_path}'."
          end
        end

        private
        def get_file_permission(pem_key_path)
          begin
            file_stats = File.stat(pem_key_path)
          rescue
            return nil
          end
          base_10_file_permission = file_stats.mode()
          base_8_file_permission = base_10_file_permission.to_s(8)
          return base_8_file_permission
        end

        def get_pem_key_path()
          return @context.get_user_config_provider().get_aws_credential().get_secret_key_path()
        end

      end
    end
  end
end
