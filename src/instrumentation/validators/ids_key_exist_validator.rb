module Instrumentation
  module Validators
    class IdsKeyExistValidator

      def initialize(keys)
        @keys = keys
      end

      def execute(parsed_instrumentors)
        has_key = []
        @keys.each do |key|
          parsed_instrumentors.each do |instrumentor|
            if instrumentor.key?(key)
              has_key.push(instrumentor)
            end
          end
        end

        unless has_key.count() == parsed_instrumentors.count()
          missing = parsed_instrumentors.count() - has_key.count()
          message = get_error_msg(missing)
          return message
        end
      end

      private
      def get_error_msg(missing)
        if missing > 1
          return "#{missing} instrumentation definitions in deploy_config are missing #{@keys}"
        else
          return "#{missing} instrumentation definition in deploy_config is missing #{@keys}"
        end
      end

    end
  end
end


