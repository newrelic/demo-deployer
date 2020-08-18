require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/command_line/provider"

describe "Commandline::Provider" do
  let(:context_builder){ Tests::ContextBuilder.new() }
  let(:options)  { { user_config: 'path1/user.json', deploy_config: 'path1/path2/deploy.json' } }
  let(:provider) { CommandLine::Provider.new(context_builder, options) }
  let(:file_content) { {thing: 'one'} }
  
  it "should create provider" do
    expect(provider).wont_be_nil
  end

  describe "get_user_config_content" do
    it "should open file and return content" do
      File.expects(:read).returns(file_content)
      expect(provider.get_user_config_content()).must_equal(file_content)
    end
  end

  describe "get_deploy_config_file" do
    it "should open file and return content" do
      File.expects(:read).returns(file_content)
      expect(provider.get_deployment_config_content()).must_equal(file_content)
    end
  end

  describe "get_user_config_name" do
    filename = "user"
    it "should return the user_config filename" do
      expect(provider.get_user_config_name()).must_equal(filename) 
    end
  end

  describe "get_deploy_config_name" do
    filename = "deploy"
    it "should return the deploy_config filename" do
      expect(provider.get_deploy_config_name()).must_equal(filename) 
    end
  end
  
  describe "get_deployment_name" do
    it "should return the deployment name" do
      expect(provider.get_deployment_name()).must_equal("user-deploy")
    end
  end

end