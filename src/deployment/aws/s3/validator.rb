require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"
require "./src/common/validators/max_length_validator"
require_relative "s3_name_syntax_list_validator"

module Deployment
  module Aws
    module S3
      class Validator

        def initialize(services,
            context,
            bucket_name_max_length_validator = Common::Validators::MaxLengthValidator.new("bucket_name", 63, "bucket_name should be 63 characters at most"),
            bucket_name_syntax_list_validator = S3NameSyntaxListValidator.new("bucket_name", "S3 Bucket name syntax error")
          )
          @services = services
          @context = context
          @bucket_name_max_length_validator = bucket_name_max_length_validator
          @bucket_name_syntax_list_validator = bucket_name_syntax_list_validator
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Aws/S3/Validator execute()")
          validators = [
            lambda { return @bucket_name_max_length_validator.execute(resources) },
            lambda { return @bucket_name_syntax_list_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end
    end
  end
end