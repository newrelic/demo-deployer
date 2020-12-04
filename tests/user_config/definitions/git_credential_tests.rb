require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/definitions/git_credential"
require "./src/user_config/credential_factory"

describe "UserConfig::Definitions::GitCredential" do

    describe "git" do
        let(:my_personal_access_token) { "my access token"}
        let(:another_personal_access_token) { "another access token"}
        let(:user_config) { {
            "myusername" => my_personal_access_token,
            "anotherusername" => another_personal_access_token
            } }
        let(:credential) { UserConfig::Definitions::GitCredential.new("git", UserConfig::CredentialFactory.get_credential_query_lambda(user_config)) }

        it "should return access token value" do
            credential.get_personal_access_token("myusername").must_equal(my_personal_access_token)
            credential.get_personal_access_token("anotherusername").must_equal(another_personal_access_token)
        end
        
        it "should return nil token value when username doesnt exist" do
            credential.get_personal_access_token("unknown").must_be_nil()
        end

        it "should return all git username" do
            all_credentials = credential.to_h()
            all_credentials["myusername"].must_include("protected")
            all_credentials["myusername"].wont_include("access")
            all_credentials["anotherusername"].must_include("protected")
            all_credentials["anotherusername"].wont_include("access")
        end

    end

end
