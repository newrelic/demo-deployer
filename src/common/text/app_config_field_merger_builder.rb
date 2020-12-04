require "./src/common/logger/logger_factory"
require_relative "field_merger_builder"
require_relative "field_merger_finder"
require_relative "global_field_merger_builder"

module Common
  module Text
    class AppConfigFieldMergerBuilder
      def initialize(field_merger_builder = nil)
        @field_merger_builder = field_merger_builder || Common::Text::FieldMergerBuilder.new()
      end

      def with_new_relic_urls(context)
        unless context.nil?
          urls = context.get_app_config_provider().get_new_relic_urls()
          new_relic_credential = context.get_user_config_provider().get_new_relic_credential()
          region = "us"

          unless new_relic_credential.nil?
            specified_region = new_relic_credential.get_region()
            region = specified_region ? specified_region.downcase() : region
          end
          
          region_urls = urls[region]
          unless region_urls.nil?
            region_urls.each do | key, value |
              add_field_merger_definition(["app_config", "newrelic", key], value)
            end
          end
        end
        return self
      end

      def with_global(context)
        merger = GlobalFieldMergerBuilder.create(context)
        @field_merger_builder.append_definitions(merger.get_definitions())
        return self
      end

      def build()
        return @field_merger_builder.build()
      end

      def self.create(context)
        instance = AppConfigFieldMergerBuilder.new()
        instance.with_global(context)
        instance.with_new_relic_urls(context)

        merger = instance.build()
        return merger
      end

      private
      
      def add_field_merger_definition(key, value)
        unless key.nil? || value.nil?
          @field_merger_builder.create_definition(key, value)
        end
      end

    end
  end
end
