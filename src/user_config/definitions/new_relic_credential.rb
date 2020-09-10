require './src/infrastructure/definitions/aws/aws_resource'

module UserConfig
  module Definitions
      class NewRelicCredential

        def initialize (user_config_query_lambda)
          @user_config_query_lambda = user_config_query_lambda
        end

        # def get_account_api_key()
        #   return @user_config_query_lambda.call("credentials.newRelic.apiKeys.account")
        # end

        # def get_admin_api_key()
        #   return @user_config_query_lambda.call("credentials.newRelic.apiKeys.admin")
        # end

        def get_license_key()
          return @user_config_query_lambda.call("licenseKey")
        end

        def get_api_key()
          return @user_config_query_lambda.call("nrApiKey")
        end

        def get_admin_api_key()
          return @user_config_query_lambda.call("nrAdminApiKey")
        end

        def get_insights_api_key()
          return @user_config_query_lambda.call("insightsInsertApiKey")
        end

        def get_account_id()
          return @user_config_query_lambda.call("accountId")
        end

        def get_account_root_id()
          return @user_config_query_lambda.call("accountRootId")
        end

        def get_region()
          return @user_config_query_lambda.call("nrRegion")
        end

        def get_collector_url()
          return @user_config_query_lambda.call("urls.collector")
        end

        def get_api_url()
          return @user_config_query_lambda.call("urls.api")
        end

        def get_infra_collector_url()
          return @user_config_query_lambda.call("urls.infraCollector")
        end

        def get_lambda_url()
          return @user_config_query_lambda.call("urls.lambda")
        end

        def get_infra_command_url()
          return @user_config_query_lambda.call("urls.infraCommand")
        end

        def get_identity_url()
          return @user_config_query_lambda.call("urls.identity")
        end

        def get_logging_url()
          return @user_config_query_lambda.call("urls.logging")
        end

        def get_cloud_collector_url()
          return @user_config_query_lambda.call("urls.cloudCollector")
        end

        def to_h()
          items = {}
          add_if_exist(items, "license_key", get_license_key())
          add_if_exist(items, "nr_api_key", get_api_key())
          add_if_exist(items, "nr_admin_api_key", get_admin_api_key())
          add_if_exist(items, "insights_insert_api_key", get_insights_api_key())
          add_if_exist(items, "account_id", get_account_id())
          add_if_exist(items, "account_root_id", get_account_root_id())
          add_if_exist(items, "nr_region", get_region())
          add_if_exist(items, "nr_collector_url", get_collector_url())
          add_if_exist(items, "nr_api_url", get_api_url())
          add_if_exist(items, "nr_infra_collector_url", get_infra_collector_url())
          add_if_exist(items, "nr_infra_command_url", get_infra_command_url())
          add_if_exist(items, "nr_identity_url", get_identity_url())
          add_if_exist(items, "nr_logging_url", get_logging_url())
          add_if_exist(items, "nr_cloud_collector_url", get_cloud_collector_url())
          return items
        end

        def add_if_exist(items, name, value)
          unless value.nil?
            items[name] = value
          end
        end

    end
  end
end
