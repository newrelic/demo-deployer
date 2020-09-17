require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"
require_relative "s3_name_syntax_list_validator"

module Deployment
  module Aws
    module S3
      class Validator

        def initialize(services,
            context,
            bucket_name_syntax_list_validator = S3NameSyntaxListValidator.new(lambda { |resource| return resource.get_bucket_name() }, "S3 Bucket name syntax error")
          )
          @services = services
          @context = context
          @bucket_name_syntax_list_validator = bucket_name_syntax_list_validator
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Aws/S3/Validator execute()")
          validators = [
            lambda { return @bucket_name_syntax_list_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end
    end
  end
end