require "./src/common/validators/file_exist"
require "./src/common/validators/validator"

module UserConfig
  module Validators
    class GcpValidator

      def initialize(
        auth_kind_validator = Common::Validators::FieldExistValidator.new("auth_kind", "auth_kind is missing for gcp credential:"),
        service_account_email_validator = Common::Validators::FieldExistValidator.new("service_account_email", "service_account_email is missing for gcp credential:"),
        service_account_file_validator = Common::Validators::FieldExistValidator.new("service_account_file", "service_account_file is missing for gcp credential:"),
        project_validator = Common::Validators::FieldExistValidator.new("project", "project is missing for gcp credential:"),
        scopes_validator = Common::Validators::FieldExistValidator.new("scopes", "scopes is missing for gcp credential:"),
        region_validator = Common::Validators::FieldExistValidator.new("region", "region is missing for gcp credential:"),
        service_account_file_exist_validator = Common::Validators::FileExist.new("A valid gcp service account file could not be found in the path defined")
        )
        @auth_kind_validator = auth_kind_validator
        @service_account_email_validator = service_account_email_validator
        @service_account_file_validator = service_account_file_validator
        @project_validator = project_validator
        @scopes_validator = scopes_validator
        @region_validator = region_validator
        @service_account_file_exist_validator = service_account_file_exist_validator
      end

      def execute(gcp_configs)
        validators = [
          lambda { return @auth_kind_validator.execute(gcp_configs) },
          lambda { return @service_account_email_validator.execute(gcp_configs) },
          lambda { return @service_account_file_validator.execute(gcp_configs) },
          lambda { return @project_validator.execute(gcp_configs) },
          lambda { return @scopes_validator.execute(gcp_configs) },
          lambda { return @region_validator.execute(gcp_configs) },
        ]
        gcp_configs.each do |gcp_config|
          validators.push(
            lambda { return @service_account_file_exist_validator.execute(gcp_config["service_account_file"]) }
          )
        end

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end