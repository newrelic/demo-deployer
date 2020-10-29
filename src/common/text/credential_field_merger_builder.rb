require "./src/common/logger/logger_factory"
require_relative "field_merger_builder"
require_relative "field_merger_finder"
require_relative "global_field_merger_builder"

module Common
  module Text
    class CredentialFieldMergerBuilder
      def initialize(field_merger_builder = nil)
        @field_merger_builder = field_merger_builder || Common::Text::FieldMergerBuilder.new()
      end

      def with_git(credentials)
        unless credentials.nil?
          usernames = credentials.get_usernames()
          (usernames || []).each do |username|
            token = credentials.get_personal_access_token(username)
            unless token.nil?
              user_access_token = "#{username}:#{token}"
              add_field_merger_definition(["credential", "git", username], user_access_token)
            end
          end
        end
        return self
      end

      def with_new_relic(credentials)
        unless credentials.nil?
          no_provider_prefix = nil
          new_relic_credential = credentials.to_h(no_provider_prefix)

          new_relic_credential.each do | key, value |
            add_field_merger_definition(["credential", "newrelic", key], value)
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
        instance = CredentialFieldMergerBuilder.new()
        instance.with_global(context)

        git_credential = context.get_user_config_provider().get_git_credentials()
        unless git_credential.nil?
          instance.with_git(git_credential)
        end

        newrelic_credential = context.get_user_config_provider().get_new_relic_credential()
        unless newrelic_credential.nil?
          instance.with_new_relic(newrelic_credential)
        end

        merger = instance.build()
        git_finder = FieldMergerFinder.new("credential", "git", "*")
        merger.add_finder(git_finder)
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
