require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/app_config/merge_files"

describe "AppConfig::MergeFiles" do
  let(:default) { {"first"=>{"key1"=>"value1", "key2"=>"value2"}} }
  let(:override) { {"first"=>{"key2"=>"value2","key1"=>"value1"}} }
  let(:merge_files) { AppConfig::MergeFiles.new() }
  
  it "should create MergeFiles" do
    merge_files.wont_be_nil
  end
  
  describe "execute" do

    it "should return default if files are identical" do
      expect(merge_files.execute(default, override)).must_equal(default)
    end

    it "should return a combination file if files are not identical" do
      default = {"first"=>{"key1"=>"value1", "key2"=>"value2"},"second"=>{}} 
      override = {"first"=>{"key2"=>"value2","key1"=>"value3"}}
      combined = {"first"=>{"key2"=>"value2", "key1"=>"value3"}, "second"=>{}}
      
      expect(merge_files.execute(default, override)).must_equal(combined)
    end

  end
end