require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/validators/git_validator"

describe "UserConfig::Validators::GitValidator" do
  let(:config) { [] }
  let(:validator) { UserConfig::Validators::GitValidator.new() }

  it "should create validator" do
    validator.wont_be_nil
  end
end