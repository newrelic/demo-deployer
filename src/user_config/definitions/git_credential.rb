module UserConfig
  module Definitions
    class GitCredential

      def initialize (user_config_query_lambda)
        @user_config_query_lambda = user_config_query_lambda
      end

      def get_personal_access_token(username)
        return @user_config_query_lambda.call(username)
      end

      def get_usernames()
        usernames = []
        all = @user_config_query_lambda.call("")
        (all || {}).each do |key, value|
          usernames.push(key)
        end
        return usernames
      end
      
      def to_h()
        output = {}
        usernames = get_usernames()
        usernames.each do |username|
          output[username] = "****protected****"
        end
        return output
      end

    end
  end
end