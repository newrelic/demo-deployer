module Instrumentation
  module Validators
    class InstrumentOnlyOnceValidator

      def initialize(key_name, error_message = nil)
        @key_name = key_name
        @error_message = error_message || "Instrumentation defined more than once: "
      end

      def execute(parsed_instrumentors, ids)
        invalid = []
        reference_count = Hash.new(0)
        (parsed_instrumentors || []).each do |instrumentor|
          instrumentor_ids = instrumentor[@key_name]
          (instrumentor_ids || []).each { |instrumentor_id| reference_count[instrumentor_id] += 1  }
        end

        (ids || []).each do |id|
          unless reference_count[id].nil?()
            if reference_count[id] > 1
              invalid.push(id)
            end
          end
        end

        if invalid.compact().length() > 0
          message = invalid.join(", ")
          return "#{@error_message}#{message}"
        end

        return nil
      end

    end
  end
end
