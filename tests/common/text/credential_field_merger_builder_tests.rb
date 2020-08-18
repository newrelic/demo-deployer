require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/user_config/definitions/git_credential"
require "./src/user_config/credential_factory"
require "./src/common/text/credential_field_merger_builder"

describe "Common::Text::CredentialFieldMergerBuilder" do
  let(:user_config) { {} }
  let(:usernames) { [] }
  let(:my_personal_access_token) { "my access token"}
  let(:another_personal_access_token) { "another access token"}
  let(:no_token_credential_stub) { m = mock(); m.stubs(:get_personal_access_token); m.stubs(:get_usernames).returns(usernames); m }
  let(:credentials) { UserConfig::Definitions::GitCredential.new(UserConfig::CredentialFactory.get_credential_query_lambda(user_config)) }
  let(:builder)  { Common::Text::CredentialFieldMergerBuilder.new() }

  it "should build empty" do
    builder.build().wont_be_nil()
  end

  it "should build single git credential" do
    given_git_credential("myusername", my_personal_access_token)
    fields = builder.with_git(credentials).build()
    fields.get_definitions_key().length().must_equal(1)
    fields.get_definitions_key()[0].must_equal("[credential:git:myusername]")
  end
  
  it "should build multiple git credential" do
    given_git_credential("myusername", my_personal_access_token)
    given_git_credential("anotherusername", another_personal_access_token)
    fields = builder.with_git(credentials).build()
    fields.get_definitions_key().length().must_equal(2)
  end

  it "should NOT build git credential when not exist" do
    given_git_credential("myusername", my_personal_access_token)
    fields = builder.with_git(no_token_credential_stub).build()
    fields.get_definitions_key().length().must_equal(0)
  end

  def given_git_credential(username, token)
    user_config[username] = token
    usernames.push(username)
  end

end