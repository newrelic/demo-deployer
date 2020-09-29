module Deployment
  class InstrumentorItemExistValidator

    def initialize(error_message = nil)
      @error_message = error_message || "Error"
    end

    def execute(instrumentors)
      missing = []

      (instrumentors || []).each do |instrumentor|
        item_id = instrumentor.get_item_id()
        if item_id.nil?
          missing.push(instrumentor.to_s())
        end
      end

      if missing.size() > 0
        return "#{@error_message} #{missing.join(", ")}"
      end

      return nil
    end

  end
end