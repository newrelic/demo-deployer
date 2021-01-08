require "fileutils"
require_relative 'credential'

module UserConfig
  module Definitions
    class SecretsCredential < Credential

      def initialize (provider, user_config_query_lambda)
        super(provider, user_config_query_lambda)
      end

      def to_h(key_prefix = @provider)
        return_all = nil
        return query(return_all).clone()
      end

    end
  end
end
