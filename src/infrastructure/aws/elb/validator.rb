require_relative "listener_validator"

module Infrastructure
  module Aws
    module Elb
      class Validator

        def initialize(max_listeners, listener_validator = nil)
          @max_listeners = max_listeners
          @listener_validator = listener_validator
        end

        def execute(resources)
          validators = [
              lambda { return get_listener_validator().execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

        private
        def get_listener_validator()
          return @listener_validator ||= ListenerValidator.new(@max_listeners)
        end
      end

    end
  end
end