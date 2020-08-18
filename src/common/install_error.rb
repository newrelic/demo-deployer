module Common
  class InstallError < StandardError
    def initialize(msg, install_errors = [])
      @validation_errors = install_errors
      @message = msg
      super(msg)
    end

    def to_s()
      @message + "\n" + @validation_errors.join(', ')
    end
  end
end