require "./src/common/validators/file_exist"
require "./src/common/validators/validator"

module UserConfig
  module Validators
    class AzureValidator

      def initialize(
          client_id_validator = nil,
          tenant_validator = nil,
          subscription_id_validator = nil,
          secret_validator = nil,
          region_validator = nil,
          ssh_public_key_validator = nil,
          ssh_public_key_file_validator = nil
        )
        @client_id_validator = client_id_validator || Common::Validators::FieldExistValidator.new("client_id", "client_id is missing for azure credential:")
        @tenant_validator = tenant_validator || Common::Validators::FieldExistValidator.new("tenant", "tenant is missing for azure credential:")
        @subscription_id_validator = subscription_id_validator || Common::Validators::FieldExistValidator.new("subscription_id", "subscription_id is missing for azure credential:")
        @secret_validator = secret_validator || Common::Validators::FieldExistValidator.new("secret", "secret is missing for azure credential:")
        @region_validator = region_validator || Common::Validators::FieldExistValidator.new("region", "region is missing for azure credential:")
        @ssh_public_key_validator = ssh_public_key_validator || Common::Validators::FieldExistValidator.new("sshPublicKeyPath", "sshPublicKeyPath is missing for azure credential:")
        @ssh_public_key_file_validator = ssh_public_key_file_validator || Common::Validators::FileExist.new("A valid SSH public key file could not be found in the path defined")
      end

      def execute(azure_configs)
        validators = [
          lambda { return @client_id_validator.execute(azure_configs) },
          lambda { return @tenant_validator.execute(azure_configs) },
          lambda { return @subscription_id_validator.execute(azure_configs) },
          lambda { return @secret_validator.execute(azure_configs) },
          lambda { return @region_validator.execute(azure_configs) },
          lambda { return @ssh_public_key_validator.execute(azure_configs) },
        ]
        azure_configs.each do |azure_config|
          validators.push(
            lambda { return @ssh_public_key_file_validator.execute(azure_config["sshPublicKeyPath"]) }
          )
        end

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end