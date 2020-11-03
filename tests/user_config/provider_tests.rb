require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/provider"

describe "UserConfig" do
  describe "Provider" do 
    let(:user_config) {{"credentials"=>{}}}
    let(:fake_context) {}
    let(:provider) { UserConfig::Provider.new(fake_context, user_config) }

    it "should create provider" do
      provider.wont_be_nil
    end

    describe "newrelic" do
      let(:new_relic_license_key) {"abcdef"}
      let(:new_relic_collector_url) {"http://collector.newrelic.com"}
      let(:user_config) {{ "credentials"=>{"newrelic"=>{"licenseKey"=>new_relic_license_key, "urls"=>{"collector"=>new_relic_collector_url} }} }}

      it "should return newrelic credential license key" do
        credential = provider.get_credential("newrelic")
        credential.wont_be_nil()
        credential.get_license_key().must_equal(new_relic_license_key)
      end  
      
      it "should return newrelic credential collector url" do
        credential = provider.get_credential("newrelic")
        credential.wont_be_nil()
        credential.get_collector_url().must_equal(new_relic_collector_url)
      end  
    end
    
    describe "aws" do
      let(:aws_access_key) {"fddsffdfg"}
      let(:user_config) {{ "credentials"=>{"aws"=>{"apiKey"=>aws_access_key }} }}

      it "should return aws credential api key" do
        credential = provider.get_aws_credential()
        credential.wont_be_nil()
        credential.get_access_key().must_equal(aws_access_key)
      end
    end

    describe "git" do
      let(:my_personal_access_token) { "my access token"}
      let(:user_config) {{ "credentials"=>{"git"=>{"myusername"=>my_personal_access_token}} }}
      
      it "should return git credential" do
        credential = provider.get_git_credentials()
        credential.wont_be_nil()
        credential.get_personal_access_token("myusername").must_equal(my_personal_access_token)
      end
    end

  end
end
