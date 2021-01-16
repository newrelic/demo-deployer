require './src/common/json_parser'

module Summary
  # Class responsible for validating the 'footnote' field of a deployment config.
  class FootnoteValidator
    # @param [Common::JsonParser] json
    def initialize(json = nil)
      @json = json || Common::JsonParser.new
    end

    # Run validation
    # @param [String] deploy_config - The content of the deployment config file represented as a JSON string.
    def execute(deploy_config)
      deploy_config_output = @json.get(deploy_config, 'output')
      # if the output section is nil, footnote is nil. If it does exist, try get the footnote field.
      raw_footnote = deploy_config_output.nil? ? nil : deploy_config_output['footnote']
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
