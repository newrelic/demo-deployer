
require "./src/common/validators/validator"
require "./src/common/validators/file_exist"
require "./src/infrastructure/aws/ec2/pem_key_permission_validator"

module Infrastructure
  module Aws
    module EC2
      class PemKeyValidator

        def initialize(context,
                       secret_key_path_exisits_validator = nil,
                       secret_key_path_file_validator = nil,
                       pem_key_permission_validator = nil)
          @context = context
          @secret_key_path_exisits_validator = secret_key_path_exisits_validator
          @secret_key_path_file_validator = secret_key_path_file_validator
          @pem_key_permission_validator = pem_key_permission_validator
        end

        def execute()
          validators = [
            lambda { return get_secret_key_path_exisits_validator().execute([get_aws_credentials_as_hash()]) },
            lambda { return secret_key_path_file_validator().execute(get_pem_key_path()) },
            lambda { return get_pemkey_permission_validator().execute() },
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

        private

        def get_secret_key_path_exisits_validator()
          return @secret_key_path_exisits_validator ||= Common::Validators::FieldExistValidator.new("secret_key_path", "secret_key_path is missing for aws credential:")
        end


        def secret_key_path_file_validator()
          return @secret_key_path_file_validator ||= Common::Validators::FileExist.new("A valid secret file could not be found in the path defined")
        end

        def get_pemkey_permission_validator()
          return @pem_key_permission_validator ||= Infrastructure::Aws::EC2::PemKeyPermissionValidator.new(@context)
        end

        def get_aws_credentials_as_hash()
          return @context.get_user_config_provider().get_aws_credential().to_h()
        end

        def get_pem_key_path()
          return @context.get_user_config_provider().get_aws_credential().get_secret_key_path()
        end

      end
    end
  end
end
