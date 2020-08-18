require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validators/provider_validator_factory"

describe "UserConfig::Validators::ProviderValidatorFactory" do
  let(:configs) { [] }
  let(:factory) { UserConfig::Validators::ProviderValidatorFactory.new() }

  it "should create factory" do
    factory.wont_be_nil
  end

  it "should create empty array when no configs provided" do
    factory.create_validators(configs).must_be_empty()
  end

  it "should create a AWS provider validator" do
    given_config("aws")
    factory.create_validators(configs).count.must_equal(1)
  end

  it "should create a Azure provider validator" do
    given_config("azure")
    factory.create_validators(configs).count.must_equal(1)
  end
  
  it "should create a Git provider validator" do
    given_config("git")
    factory.create_validators(configs).count.must_equal(1)
  end

  def given_config(provider)
    configs.push({provider=> {}})
  end

end