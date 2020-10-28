require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/user_config/definitions/git_credential"
require "./src/user_config/definitions/new_relic_credential"
require "./src/user_config/credential_factory"
require "./src/common/text/credential_field_merger_builder"
require "./tests/context_builder"

describe "Common::Text::CredentialFieldMergerBuilder" do
  let(:git_user_config) { {} }
  let(:nr_user_config) { {} }
  let(:usernames) { [] }
  let(:my_personal_access_token) { "my access token"}
  let(:another_personal_access_token) { "another access token"}
  let(:no_token_credential_stub) { m = mock(); m.stubs(:get_personal_access_token); m.stubs(:get_usernames).returns(usernames); m }
  let(:git_credentials) { UserConfig::Definitions::GitCredential.new("git", UserConfig::CredentialFactory.get_credential_query_lambda(git_user_config)) }
  let(:newrelic_credentials) { UserConfig::Definitions::NewRelicCredential.new("newrelic", UserConfig::CredentialFactory.get_credential_query_lambda(nr_user_config)) }
  let(:builder)  { Common::Text::CredentialFieldMergerBuilder.new() }

  it "should build empty" do
    builder.build().wont_be_nil()
  end

  it "should build single git credential" do
    given_git_credential("myusername", my_personal_access_token)
    fields = builder.with_git(git_credentials).build()
    fields.get_definitions_key().length().must_equal(1)
    fields.get_definitions_key()[0].must_equal("[credential:git:myusername]")
  end
  
  it "should build multiple git credential" do
    given_git_credential("myusername", my_personal_access_token)
    given_git_credential("anotherusername", another_personal_access_token)
    fields = builder.with_git(git_credentials).build()
    fields.get_definitions_key().length().must_equal(2)
  end

  it "should NOT build git credential when not exist" do
    given_git_credential("myusername", my_personal_access_token)
    fields = builder.with_git(no_token_credential_stub).build()
    fields.get_definitions_key().length().must_equal(0)
  end

  it "should NOT build newrelic credential when not exist" do 
    fields = builder.with_new_relic(nil).build()
    fields.get_definitions_key().length().must_equal(0)
  end

  it "should build newrelic credential" do
    given_newrelic_credential("licenseKey", "test")
    given_newrelic_credential("nrRegion", "test2")
    fields = builder.with_new_relic(newrelic_credentials).build()
    definitions = fields.get_definitions_key()
    definitions.length().must_equal(2)
    definitions.must_include("[credential:newrelic:license_key]")
    definitions.must_include("[credential:newrelic:region]")
  end

  it "should not include new relic fields without values" do
    given_newrelic_credential("licenseKey", nil)
    given_newrelic_credential("nrRegion", "test")
    fields = builder.with_new_relic(newrelic_credentials).build()
    definitions = fields.get_definitions_key()
    definitions.length().must_equal(1)
    definitions.wont_include("[credential:newrelic:license_key]")
    definitions.must_include("[credential:newrelic:region]")
  end

  def given_git_credential(username, token)
    git_user_config[username] = token
    usernames.push(username)
  end

  def given_newrelic_credential(key, value)
    nr_user_config[key] = value
  end
end
