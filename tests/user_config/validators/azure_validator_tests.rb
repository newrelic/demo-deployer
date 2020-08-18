require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validators/azure_validator"

describe "UserConfig::Validators::AzureValidator" do
  let(:azure_configs) { [] }
  let(:client_id_validator) { m = mock(); m.stubs(:execute); m }
  let(:tenant_validator) { m = mock(); m.stubs(:execute); m }
  let(:subscription_id) { m = mock(); m.stubs(:execute); m }
  let(:secret) { m = mock(); m.stubs(:execute); m }
  let(:secret_key_path_validator) { m = mock(); m.stubs(:execute); m }
  let(:region_validator) { m = mock(); m.stubs(:execute); m }
  let(:ssh_public_key_validator) { m = mock(); m.stubs(:execute); m }
  let(:ssh_public_key_file_validator) { m = mock(); m.stubs(:execute); m } 
  let(:validator) { UserConfig::Validators::AzureValidator.new(
    client_id_validator,
    tenant_validator,
    subscription_id,
    secret,
    region_validator,
    ssh_public_key_validator,
    ssh_public_key_file_validator
    ) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should execute client_id_validator" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    client_id_validator.expects(:execute)
    validator.execute(azure_configs)
  end

  it "should execute tenant_validator" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    tenant_validator.expects(:execute)
    validator.execute(azure_configs)
  end
  
  it "should execute subscription_id" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    subscription_id.expects(:execute)
    validator.execute(azure_configs)
  end
  
  it "should execute secret" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    secret.expects(:execute)
    validator.execute(azure_configs)
  end

  it "should execute region_validator" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    region_validator.expects(:execute)
    validator.execute(azure_configs)
  end

  it "should execute ssh_public_key_validator" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    ssh_public_key_validator.expects(:execute)
    validator.execute(azure_configs)
  end

  it "should execute ssh_public_key_file_validator" do
    given_azure_credential("my client id", "my tenant", "my subscription id", "my secret", "my region", "my ssh public key path")
    ssh_public_key_file_validator.expects(:execute)
    validator.execute(azure_configs)
  end

  def given_azure_credential(client_id = nil, tenant = nil, subscription_id = nil, secret = nil, region = nil, sshPublicKeyPath = nil)
    azure_config = { }
    unless client_id.nil?
      azure_config["client_id"] = client_id
    end
    unless tenant.nil?
      azure_config["tenant"] = tenant
    end
    unless subscription_id.nil?
      azure_config["subscription_id"] = subscription_id
    end
    unless secret.nil?
      azure_config["secret"] = secret
    end
    unless region.nil?
      azure_config["region"] = region
    end
    unless sshPublicKeyPath.nil?
      azure_config["sshPublicKeyPath"] = sshPublicKeyPath
    end
    azure_configs.push(azure_config)
  end

end