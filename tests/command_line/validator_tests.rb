require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/command_line/validator"

describe "Commandline::Validator" do
  let(:validator) { CommandLine::Validator.new() }
  let(:options) { {} }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should return error when there is no config option" do
    validator.execute(options).wont_be_empty
  end

  describe "file path" do
    let(:options) { { user_config: "path/file1", deploy_config: "path/file2" } }

    it "should find file" do
      File.stubs(:exist?).returns(true)
      File.stubs(:read).returns('{ "a": 123}')
      validator.execute(options).must_be_empty
    end

    it "should not find file" do
      File.stubs(:exist?).returns(false)
      validator.execute(options).wont_be_empty
    end
  end

end