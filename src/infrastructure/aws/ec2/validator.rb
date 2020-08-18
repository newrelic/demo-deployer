require "./src/common/validators/size_validator"

module Infrastructure
  module Aws
    module Ec2
      class Validator

        def initialize(sizes_supported, size_validator = nil)
          @sizes_supported = sizes_supported
          @size_validator = size_validator
        end

        def execute(resources)
          validators = [
            lambda { return get_size_validator().execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

        private
        def get_size_validator()
          return @size_validator ||= Common::Validators::SizeValidator.new(@sizes_supported)
        end

      end
    end
  end
end