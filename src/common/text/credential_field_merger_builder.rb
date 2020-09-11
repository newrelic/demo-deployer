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
              @field_merger_builder.create_definition(["credential", "git", username], user_access_token)
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
        instance = CredentialFieldMergerBuilder.new()
        credentials = context.get_user_config_provider().get_git_credentials()
        instance.with_git(credentials)
        instance.with_global(context)
        merger = instance.build()
        finder = FieldMergerFinder.new("credential", "git", "*")
        merger.add_finder(finder)
        return merger
      end

    end
  end
end