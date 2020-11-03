require "./src/common/type_repository"
require "./src/user_config/definitions/new_relic_credential"
require "./src/user_config/definitions/aws_credential"
require "./src/user_config/definitions/azure_credential"
require "./src/user_config/definitions/gcp_credential"
require "./src/user_config/definitions/git_credential"

module UserConfig
  class CredentialFactory

    def initialize(
        type_repository = nil,
        supported_types = nil
      )
      @type_repository = type_repository
      @supported_types = supported_types
    end

    def create(context, config_credential, credential_key)
      repository = get_repository()
      type = repository.get(credential_key)
      unless type.nil?
        return type.new(context, credential_key, CredentialFactory.get_credential_query_lambda(config_credential))
      end
      return nil
    end

    def self.get_credential_query_lambda(config_credential)
      return lambda { |lookup| return CredentialFactory.query(lookup, config_credential) }
    end

    private
    def get_key_lookup_lambda()
      return lambda {|key| return key}
    end

    def get_repository()
      return @type_repository ||= Common::TypeRepository.new(get_supported_types(), get_key_lookup_lambda(), lambda { return nil })
    end

    def get_supported_types()
      return @supported_types ||= {
        "newrelic" => UserConfig::Definitions::NewRelicCredential,
        "aws" => UserConfig::Definitions::AwsCredential,
        "azure" => UserConfig::Definitions::AzureCredential,
        "gcp" => UserConfig::Definitions::GcpCredential,
        "git" => UserConfig::Definitions::GitCredential
      }
    end

    def self.query(lookup, config_credential)
      current = config_credential
      parts = lookup.split(".")
      parts.each do |part|
        if current.key?(part)
          current = current[part]
        else
          return nil
        end
      end
      return current
    end
  end
end
