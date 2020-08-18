require './src/common/type_repository'

require_relative "error_validator"

module Common
  module Validators
    class ValidatorFactory

      def initialize(
          supported_types,
          key_resolver_lambda,
          validator_construct_lambda = nil,
          type_repository = nil,
          default_type_resolver_lambda = nil)
        @supported_types = supported_types
        @key_resolver_lambda = key_resolver_lambda
        @validator_construct_lambda = validator_construct_lambda
        @type_repository = type_repository
        @default_type_resolver_lambda = default_type_resolver_lambda       
      end

      def create_validators(resources)
        validators = []
        begin
          repository = get_repository()
          grouped_resources = resources.group_by { |resource| @key_resolver_lambda.call(resource) }.values
          grouped_resources.each do |group_resources|
            type = repository.get(group_resources[0])
            if type.nil? == false
              validator = get_validator_construct_lambda().call(type)
              if validator.nil? == false
                validators.push(lambda { return validator.execute(group_resources) })
              end
            end
          end
        rescue StandardError => exception
          validators.push(lambda { return Common::Validators::ErrorValidator.new(exception.message).execute()})
        end
        return validators
      end

      private
      def get_repository()
        return @type_repository ||= Common::TypeRepository.new(get_supported_types(), @key_resolver_lambda, @default_type_resolver_lambda)
      end

      def get_validator_construct_lambda()
        return @validator_construct_lambda ||= lambda { |type| return type.new() }
      end

      def get_supported_types()
        return @supported_types ||= { }
      end

    end
  end
end