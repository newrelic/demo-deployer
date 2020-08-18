module Common
  class ValidationError < StandardError
    def initialize(msg, validation_errors = [])
      @validation_errors = validation_errors
      @message = msg
      super(msg)
    end

    def to_s()
      @message + "\n" + @validation_errors.join("\n")
    end
  end
end