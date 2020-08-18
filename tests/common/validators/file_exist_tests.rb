require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/file_exist"

describe "Common::Validators::FileExist" do
  let(:validator) { Common::Validators::FileExist.new() }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should return error when there is no file" do
    File.stubs(:exist?).returns(false)
    validator.execute("").wont_be_nil
  end

  it "should validate file cannot be read" do
    File.stubs(:exist?).returns(true)
    validator.execute("").wont_be_nil
  end
  
  it "should validate file can be read correctly" do
    File.stubs(:exist?).returns(true)
    File.stubs(:read).returns('a file content')
    validator.execute("").must_be_nil
  end

end