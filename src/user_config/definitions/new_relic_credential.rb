require_relative 'credential'

module UserConfig
  module Definitions
      class NewRelicCredential < Credential

        def initialize (provider, user_config_query_lambda)
          super(provider, user_config_query_lambda)
        end

        def get_license_key()
          return query("licenseKey")
        end

        def get_personal_api_key()
          return query("nrPersonalApiKey")
        end

        def get_admin_api_key()
          return query("nrAdminApiKey")
        end

        def get_insights_api_key()
          return query("insightsInsertApiKey")
        end

        def get_account_id()
          return query("accountId")
        end

        def get_account_root_id()
          return query("accountRootId")
        end

        def get_region()
          return query("nrRegion")
        end

        def get_collector_url()
          return query("urls.collector")
        end

        def get_api_url()
          return query("urls.api")
        end

        def get_infra_collector_url()
          return query("urls.infraCollector")
        end

        def get_lambda_url()
          return query("urls.lambda")
        end

        def get_infra_command_url()
          return query("urls.infraCommand")
        end

        def get_identity_url()
          return query("urls.identity")
        end

        def get_logging_url()
          return query("urls.logging")
        end

        def get_cloud_collector_url()
          return query("urls.cloudCollector")
        end

        def to_h(no_prefix = false)
          items = {}
          add_if_exist(items, "license_key", get_license_key(), no_prefix)
          add_if_exist(items, "personal_api_key", get_personal_api_key(), no_prefix)
          add_if_exist(items, "admin_api_key", get_admin_api_key(), no_prefix)
          add_if_exist(items, "insights_insert_api_key", get_insights_api_key(), no_prefix)
          add_if_exist(items, "account_id", get_account_id(), no_prefix)
          add_if_exist(items, "account_root_id", get_account_root_id(), no_prefix)
          add_if_exist(items, "region", get_region(), no_prefix)
          add_if_exist(items, "collector_url", get_collector_url(), no_prefix)
          add_if_exist(items, "api_url", get_api_url(), no_prefix)
          add_if_exist(items, "infra_collector_url", get_infra_collector_url(), no_prefix)
          add_if_exist(items, "infra_command_url", get_infra_command_url(), no_prefix)
          add_if_exist(items, "identity_url", get_identity_url(), no_prefix)
          add_if_exist(items, "logging_url", get_logging_url(), no_prefix)
          add_if_exist(items, "cloud_collector_url", get_cloud_collector_url(), no_prefix)
          return items
        end

        def to_h_no_prefix()
          return self.to_h(true)
        end

    end
  end
end
