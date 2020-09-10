require "./src/common/validators/validator_factory"
require_relative "lambda/validator"
require_relative "ec2/validator"
require_relative "elb/validator"
require_relative "r53ip/validator"
require_relative "s3/validator"

module Deployment
  module Aws
    class TypeValidatorFactory < Common::Validators::ValidatorFactory

      def initialize(services, context)
        @services = services
        @context = context
        super(
          {
            "lambda" => Lambda::Validator.new(@services),
            "ec2" => Ec2::Validator.new(@services),
            "elb" => Elb::Validator.new(@services, @context),
            "r53ip" => R53Ip::Validator.new(@services, @context),
            "s3" => S3::Validator.new(@services, @context),
          },
          lambda {|resource| return resource.get_type()},
          lambda {|validator| return validator}
        )
      end

    end
  end
end