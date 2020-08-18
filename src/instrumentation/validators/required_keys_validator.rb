require "./src/common/validators/not_null_or_empty_validator"

module Instrumentation
  module Validators
    class RequiredKeysValidator

      def initialize(required_keys, error_message = nil)
        @error_message = error_message || "Required fields missing from instrumentation: "
        @required_keys = required_keys
      end

      def execute(instrumentors)
        errors = []

        (@required_keys || []).each do |key|
          (instrumentors || []).each do |instrumentor|
            error = get_required_key_value_validator().execute(instrumentor[key])
            unless error.nil?()
              errors.push("'#{key}' missing from #{JSON.generate(instrumentor)}")
            end
          end
        end

        if errors.length() > 0
          message = errors.join("\n")
          return "#{@error_message}#{message}"
        end

        return nil
      end

      private
      def get_required_key_value_validator()
        return Common::Validators::NotNullOrEmptyValidator.new()
      end

    end
  end
end
