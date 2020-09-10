require "./src/common/validators/not_null_or_empty_list_validator"

module Infrastructure
  module Aws
    module S3
      class Validator

        def initialize(
          bucket_name_exist_validator = Common::Validators::NotNullOrEmptyListValidator.new("bucket_name", "The following S3 bucket have no bucket_name defined:")
          )
          @bucket_name_exist_validator = bucket_name_exist_validator
        end

        def execute(resources)
          validators = [
            lambda { return @bucket_name_exist_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end

    end
  end
end