require "./src/common/validators/error_validator"
require_relative "ec2/validator"
require_relative "elb/validator"
require_relative "lambda/validator"
require_relative "r53ip/validator"

module Infrastructure
  module Aws
    class TypeValidatorFactory < Common::Validators::ValidatorFactory

      def initialize(context)
        @context = context
        super(
          {
            "ec2" => Ec2::Validator.new(@context),
            "elb" => Elb::Validator.new(get_aws_elb_max_listeners()),
            "lambda" => Lambda::Validator.new(),
            "r53ip" => R53Ip::Validator.new()
          },
          lambda {|resource| return resource['type']},
          lambda {|validator| return validator}
        )
      end

      private

      def get_aws_elb_max_listeners()
        return @context.get_app_config_provider().get_aws_elb_max_listeners()
      end

    end
  end
end