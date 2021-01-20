require './src/common/json_parser'

module Summary
  # Class responsible for validating the 'footnote' field of a deployment config.
  class FootnoteValidator
    # @param [Common::JsonParser] json
    def initialize(json = nil)
      @json = json || Common::JsonParser.new
    end

    # Run validation
    # @param [Method] deploy_config_func - Method which can be called to return the deploy_config represented as a [Hash].
    def execute(deploy_config_func)
      deploy_config = deploy_config_func.call
      raw_footnote = deploy_config.fetch('output', {})['footnote']
      return "'footnote' field must be of type 'String' or 'Array<String>'" unless validate(raw_footnote)
    end

    private

    # Validate that raw_footnote is either a string, or an array of strings.
    # @param [String, Array<string>] raw_footnote
    # @return [Boolean] value indicating whether input is valid. true indicates valid, false indicates invalid.
    def validate(raw_footnote)
      if raw_footnote.is_a?(String)
        return true
      elsif raw_footnote.is_a?(Array)
        if raw_footnote.any? { |i| i.class != String }
          return false
        else
          # empty array
          return true
        end
      elsif raw_footnote.nil?
        # footnote wasnt found in deploy config
        return true
      else
        # not a string, an array, or nil
        return false
      end
    end
  end
end
