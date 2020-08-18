require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/directory_exist_list_validator"

describe "Common" do
  describe "Validators" do
    describe "DirectoryExistListValidator" do 
      let(:items) { [] }
      let(:error_message) { "there was a significant error while running a test" }
      let(:directory_exist_validator) { m = mock(); m.stubs(:execute) ; m }
      let(:name_lambda) { lambda { |item| return item["path"] } }
      let(:validator) { Common::Validators::DirectoryExistListValidator.new(name_lambda, error_message, directory_exist_validator) }

      it "should create validator" do
        validator.wont_be_nil
      end

      it "should validate item directory path" do
        given_item("/src/mydir")
        given_directory_exist("/src/mydir")
        validator.execute(items).must_be_nil()
      end

      it "should validate item directory does not exist" do
        given_item("/src/mydir")
        given_directory_does_not_exist("/src/mydir")
        validator.execute(items).must_include("/src/mydir")
      end

      it "should validate all items directory path" do
        given_item("/src/mydir1")
        given_item("/src/mydir2")
        given_item("/src/mydir3")
        given_directory_exist("/src/mydir1")
        given_directory_exist("/src/mydir2")
        given_directory_exist("/src/mydir3")
        validator.execute(items).must_be_nil()
      end

      it "should validate all items directory does not exist" do
        given_item("/src/mydir1")
        given_item("/src/mydir2")
        given_item("/src/mydir3")
        given_directory_does_not_exist("/src/mydir1")
        given_directory_does_not_exist("/src/mydir2")
        given_directory_does_not_exist("/src/mydir3")
        validator.execute(items).must_include("/src/mydir1")
        validator.execute(items).must_include("/src/mydir2")
        validator.execute(items).must_include("/src/mydir3")
      end

      it "should find single item not existing" do
        given_item("/src/mydir1")
        given_item("/src/mydir2")
        given_item("/src/mydir3")
        given_directory_exist("/src/mydir1")
        given_directory_does_not_exist("/src/mydir2")
        given_directory_exist("/src/mydir3")
        validator.execute(items).wont_include("/src/mydir1")
        validator.execute(items).wont_include("/src/mydir3")
      end

      def given_directory_exist(path)
        directory_exist_validator.stubs(:execute).with(path).returns(nil)
      end
      
      def given_directory_does_not_exist(path)
        directory_exist_validator.stubs(:execute).with(path).returns("Nope, not there")
      end

      def given_item(path)
        items.push({"path"=>path})
      end
    end
  end
end