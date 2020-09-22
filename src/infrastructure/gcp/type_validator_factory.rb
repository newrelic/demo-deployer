require "./src/common/validators/error_validator"
require_relative "compute/validator"

module Infrastructure
  module Gcp
    class TypeValidatorFactory < Common::Validators::ValidatorFactory

      def initialize(app_config_provider)
        @app_config_provider = app_config_provider
        super(
          {
            "compute" => Compute::Validator.new(get_supported_sizes())
          },
          lambda {|resource| return resource['type']},
          lambda {|validator| return validator}
        )
      end

      private
      def get_supported_sizes()
        return @app_config_provider.get_gcp_compute_supported_sizes()
      end

    end
  end
end