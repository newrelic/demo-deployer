require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'
require 'json'

require "./src/user_config/parser"

describe "UserConfig" do
  describe "Parser" do 
    let(:parser) { UserConfig::Parser.new() }

    it "should create parser" do
      parser.wont_be_nil
    end

    describe "execute" do
      let(:config_file) {{"credentials": {"my_provider": {"my_key": "my_value"}}}}
      let(:parsed_file) {{"credentials"=>{"my_provider"=>{"my_key"=>"my_value"}}}}

      it "should raise error when not valid JSON" do
        bad_json = "not json"
        assert_raises StandardError do
          parser.execute(bad_json)
        end
      end

      it "should return parsed JSON file" do
        JSON.expects(:parse).with(config_file).returns(parsed_file)
        parser.execute(config_file).must_equal(parsed_file)        
      end
    end

  end
end