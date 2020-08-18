require 'json'

module Common
  class TypeRepository

    def initialize(supported_types, key_resolver_lambda = nil, default_type_resolver_lambda = nil)
      @supported_types = supported_types
      @key_resolver_lambda = key_resolver_lambda
      @default_type_resolver_lambda = default_type_resolver_lambda
    end

    def get(element)
      key = element
      unless @key_resolver_lambda.nil?
        key = @key_resolver_lambda.call(element)
      end
      type = get_by_key(key, element)
      return type
    end

    private
    def get_by_key(key, element)
      if key.nil? || key.empty?
        message = "Missing key on #{JSON.generate(element, { quirks_mode: true })}. Allowed keys are [#{get_supported().keys.join(", ")}]"
        raise message
      end

      if get_supported().key?(key) == false
        if @default_type_resolver_lambda.nil? == false
          return @default_type_resolver_lambda.call()
        else
          message = "Key '#{key}' is not currently supported on #{JSON.generate(element, { quirks_mode: true })}, these keys are supported [#{get_supported().keys.join(", ")}]."
          raise message
        end
      end

      return get_supported()[key]
    end

    def get_supported()
      @supported_types ||= { }
    end

  end
end