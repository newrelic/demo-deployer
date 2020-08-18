require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/common/validators/alpha_numeric"

describe "Common" do
  describe "Validators" do
    describe "AlphaNumeric" do
      let(:validator) { Common::Validators::AlphaNumeric.new() }

      it "should create validator" do
        validator.wont_be_nil()
      end

      it "should return no error when string is alpha numeric" do
        validator.execute("str1ng").must_be_nil()
      end

      it "should return no error when using dash" do
        validator.execute("str1ng-s2").must_be_nil()
      end

      it "should return error when string is not alpha numeric" do
        strings = ["stri$g", "stri g", "stri_g", "stri.g", "stri,g"]
        strings.each do |string|
          validator.execute(string).wont_be_nil()
        end
      end

      it "should return error message prefix" do
        validator = Common::Validators::AlphaNumeric.new("MyFieldName")
        errorMessage = validator.execute("not a valid string _-$%")
        errorMessage.index("MyFieldName").must_equal(0)
      end
      
      it "should not return error message prefix" do
        validator = Common::Validators::AlphaNumeric.new("MyFieldName")
        errorMessage = validator.execute("ValidString")
        errorMessage.must_be_nil()
      end
    end

  end
end
