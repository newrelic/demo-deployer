require "./src/common/validators/error_validator"
require_relative "vm/validator"

module Infrastructure
  module Azure
    class TypeValidatorFactory < Common::Validators::ValidatorFactory

      def initialize(app_config_provider)
        @app_config_provider = app_config_provider
        super(
          {
            "vm" => Vm::Validator.new(get_supported_sizes())
          },
          lambda {|resource| return resource['type']},
          lambda {|validator| return validator}
        )
      end

      private
      def get_supported_sizes()
        return @app_config_provider.get_azure_vm_supported_sizes()
      end

    end
  end
end