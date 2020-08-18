require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/directory_exist_validator"

describe "Common" do
  describe "Validators" do
    describe "DirectoryExistValidator" do 
      let(:validator) { Common::Validators::DirectoryExistValidator.new() }

      it "should create validator" do
        validator.wont_be_nil
      end

      it "should validate directory can be read" do
        File.stubs(:directory?).returns(true)
        validator.execute("any_directory_name").must_be_nil
      end

      it "should return error when there is no directory" do
        File.stubs(:directory?).returns(false)
        validator.execute("").wont_be_nil
      end

      it "non-existent path should not be valid directory name" do
        validator.execute(nil).wont_be_nil
      end
      
      it "empty  path should not be valid directory name" do
        validator.execute("").wont_be_nil
      end

    end
  end
end