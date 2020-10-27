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
          license_key = credentials.get_license_key()
          personal_api_key = credentials.get_personal_api_key()
          admin_key = credentials.get_admin_api_key()
          insights_api_key = credentials.get_insights_api_key()
          account_id = credentials.get_account_id()
          account_root_id = credentials.get_account_root_id()
          region = credentials.get_region()
          collector_url = credentials.get_collector_url()
          api_url = credentials.get_api_url()
          infra_collector_url = credentials.get_infra_collector_url()
          lambda_url = credentials.get_lambda_url()
          infra_command_url = credentials.get_infra_command_url()
          identity_url = credentials.get_identity_url()
          logging_url = credentials.get_logging_url()
          cloud_collector_url = credentials.get_cloud_collector_url()

          add_field_merger_definition(["credential", "newrelic", "licenseKey"], license_key)
          add_field_merger_definition(["credential", "newrelic", "nrPersonalAPIKey"], personal_api_key)
          add_field_merger_definition(["credential", "newrelic", "nrAdminKey"], admin_key)
          add_field_merger_definition(["credential", "newrelic", "insightsInsertsAPIKey"], insights_api_key)
          add_field_merger_definition(["credential", "newrelic", "accountId"], account_id)
          add_field_merger_definition(["credential", "newrelic", "accountRootId"], account_root_id)
          add_field_merger_definition(["credential", "newrelic", "nrRegion"], region)
          add_field_merger_definition(["credential", "newrelic", "collectorUrl"], collector_url)
          add_field_merger_definition(["credential", "newrelic", "apiUrl"], api_url)
          add_field_merger_definition(["credential", "newrelic", "infraCollectorUrl"], infra_collector_url)
          add_field_merger_definition(["credential", "newrelic", "lambdaUrl"], lambda_url)
          add_field_merger_definition(["credential", "newrelic", "infraCommandUrl"], infra_command_url)
          add_field_merger_definition(["credential", "newrelic", "identityUrl"], identity_url)
          add_field_merger_definition(["credential", "newrelic", "loggingUrl"], logging_url)
          add_field_merger_definition(["credential", "newrelic", "cloudCollectorUrl"], cloud_collector_url)
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
        git_credentials = context.get_user_config_provider().get_git_credentials()
        newrelic_credentials = context.get_user_config_provider().get_new_relic_credential()
        instance.with_git(git_credentials)
        instance.with_new_relic(newrelic_credentials)
        instance.with_global(context)
        merger = instance.build()
        git_finder = FieldMergerFinder.new("credential", "git", "*")
        newrelic_finder = FieldMergerFinder.new("credential", "newrelic", "*")
        merger.add_finder(git_finder)
        merger.add_finder(newrelic_finder)
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
