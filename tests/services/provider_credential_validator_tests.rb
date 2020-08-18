require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/services/provider_credential_validator"

describe "Services::ProviderCredentialValidator" do
  let(:services) { [] }
  let(:error_message) { "Error" }
  let(:user_config_provider) { m=mock(); m.stubs(:get_credential); m}
  let(:validator) { Services::ProviderCredentialValidator.new(user_config_provider, error_message) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should return error(s) with empty provider_credential" do
    given_service("service_1", "")
    validator.execute(services).must_include("service_1")
  end

  it "should validate with no errors with nil provider_credential" do
    given_service("service_1")
    validator.execute(services).must_be_nil()
  end

  it "should validate with no errors with valid provider_credential" do
    given_service("service_1", "gws")
    given_user_config_credential("gws")
    validator.execute(services).must_be_nil()
  end

  it "should validate with errors with unsupported provider_credential" do
    given_service("service_1", "azurews")
    given_user_config_credential("ocean")
    validator.execute(services).must_include("service_1")
  end
end

def given_service(id, provider_credential = nil)
  service = {}
  service["id"] = id
  service["provider_credential"] = provider_credential
  services.push(service)
end

def given_user_config_credential(credential)
  user_config_provider.stubs(:get_credential).with(credential).returns("valid")
end