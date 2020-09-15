require_relative 'credential'

module UserConfig
  module Definitions
    class GitCredential < Credential

      def initialize (provider, user_config_query_lambda)
        super(provider, user_config_query_lambda)
      end

      def get_personal_access_token(username)
        return query(username)
      end

      def get_usernames()
        usernames = []
        all = query("")
        (all || {}).each do |key, value|
          usernames.push(key)
        end
        return usernames
      end

      def to_h()
        items = {}
        usernames = get_usernames()
        usernames.each do |username|
          items[username] = "****protected****"
        end
        return items
      end

    end
  end
end