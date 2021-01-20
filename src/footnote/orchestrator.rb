require './src/common/json_parser'
require './src/common/logger/logger_factory'
require './src/install/service_field_merger_builder'

module Footnote
  class Orchestrator
    # @param [Context] context
    # @param [Common::JsonParser] json
    # @param [Common::Logger::Logger] logger
    def initialize(context, json = nil, logger = nil)
      @context = context
      @json = json || Common::JsonParser.new
      @logger = logger || Common::Logger::LoggerFactory.get_logger
    end

    # Method that will print out the content of the 'footnote' field in the deployment config, with merge fields substituted.
    # @return [nil]
    def execute
      deploy_config = @context.get_command_line_provider.get_deployment_config_content
      raw_footnote = @json.get(deploy_config, 'footnote')
      string_footnote = convert_to_string(raw_footnote)
      temp_merge_fields = find_merge_fields(string_footnote)
      field_merger = get_field_merger
      merged_fields = field_merger.merge_values(temp_merge_fields)
      final_footnote = get_final_form(string_footnote, merged_fields)

      @logger.info(final_footnote)
    end

    private

    # Convert raw_footnote into a string. The important transform is when footnate is an array, and the resulting string is concatenated with line breaks between sections.
    # @param [String, Array<string>] raw_footnote
    # @return [String] String representation of the raw footnote.
    def convert_to_string(raw_footnote)
      if raw_footnote.is_a?(String)
        return raw_footnote
      elsif raw_footnote.is_a?(Array)
        return raw_footnote.join("\n")
      end
    end

    # Find all merge field substrings within string_footnote
    # @param [String] string_footnote
    # @return [Hash<string, string>] merge fields found
    def find_merge_fields(string_footnote)
      merge_fields = {}
      matches = string_footnote.scan(/(\[[^\[\]:]+(?::[^\[\]:]+)+\])/)
      matches.flatten.each do |match|
        merge_fields[match] = match
      end
      
      return merge_fields
    end

    # Get an instance of [Common::Text::FieldMerger]
    # @return [Common::Text::FieldMerger]
    def get_field_merger()
      services = @context.get_services_provider().get_services()
      provisioned_resources = @context.get_provision_provider().get_all()
      field_merger = Install::ServiceFieldMergerBuilder.new
        .with_services(services, provisioned_resources)
        .with_user_credentials(@context)
        .with_app_config(@context)
        .build()
      
      return field_merger
    end

    # Get the final form of the footnote -- all merge fields within are replaced with their corresponding values.
    # @param [String] string_footnote
    # @param [Hash<string,string>] merge_fields. Hash where (key, value) pair -> is (merge field, merged value).
      # Example: ("[service:name:ip]", "192.168.1.1")
    # @return [String] Footnote string with merge fields replaced.
    def get_final_form(string_footnote, merge_fields)
      merged_footnote = string_footnote.dup
      merge_fields.each do | key, value |
        merged_footnote.gsub!(key, value)
      end

      return merged_footnote
    end
  end
end
