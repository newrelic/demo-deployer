require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/json_file_exist"

describe "Common::Validators::JsonFileExist" do
  let(:validator) { Common::Validators::JsonFileExist.new() }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should validate can read file" do
    File.stubs(:exist?).returns(true)
    validator.execute("").wont_be_nil
  end

  it "should validate correct json file" do
    File.stubs(:exist?).returns(true)
    File.stubs(:read).returns('{ "a": 123}')
    validator.execute("").must_be_nil
  end

  it "should validate incorrect json file" do
    File.stubs(:exist?).returns(true)
    File.stubs(:read).returns('not a json content')
    validator.execute("").wont_be_nil
  end

end