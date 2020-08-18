require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validator"

describe "UserConfig" do
  describe "Validator" do

    let(:credentials) { {} }
    let(:config) { {"credentials"=>credentials} }
    let(:provider_validator_factory) { m = mock(); m.stubs(:create_validators).returns([]); m }
    let(:credentials_validator) { m = mock(); m.stubs(:execute); m }
    let(:validator) { UserConfig::Validator.new(provider_validator_factory, credentials_validator) }

    it "should create validator" do
      validator.wont_be_nil
    end

    it "should execute credential validator" do
      given_credential("aws", nil, nil, "/tmp/file.pem")
      credentials_validator.expects(:execute)
      validator.execute(config)
    end
    
    it "should execute provider_validator_factory" do
      given_credential("aws", nil, nil, "/tmp/file.pem")
      provider_validator_factory.expects(:create_validators).returns([])
      validator.execute(config)
    end

    def given_credential(provider, api_key = nil, secret_key = nil, secret_key_path = nil, region = nil)
      provider_fields = { }
      unless api_key.nil?
        provider_fields["apiKey"] = api_key
      end
      unless secret_key.nil?
        provider_fields["secretKey"] = secret_key
      end
      unless secret_key_path.nil?
        provider_fields["secretKeyPath"] = secret_key_path
      end
      unless region.nil?
        provider_fields["region"] = region
      end
      credentials[provider] = provider_fields
    end

  end    
end