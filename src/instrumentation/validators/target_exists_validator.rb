module Instrumentation
  module Validators
    class TargetExistsValidator

      def initialize(key_name, error_message = nil)
        @key_name = key_name
        @error_message = error_message || "Invalid reference(s) found in instrumentations: "
      end

      def execute(instrumentors, ids)
        missing = []
        (instrumentors || []).each do |instrumentor|
          referenced_ids = instrumentor[@key_name]
          (referenced_ids || []).each do |referenced_id|
            unless ids.any? {|id| id == referenced_id }
              missing.push(referenced_id)
            end
          end
        end

        if missing.length() > 0
          missingIds = missing.join(", ")
          return "#{@error_message}#{missingIds}"
        end
        return nil
      end

    end
  end
end
