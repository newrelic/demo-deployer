require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/service/deployment_repository"
require "./tests/context_builder.rb"

describe "Service::DeploymentRepository" do
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:repository) { Service::DeploymentRepository.new(context) }

  it "should create" do
    repository.wont_be_nil
  end

  describe "is_not_empty" do

    it "should be true" do
      ret = repository.is_not_empty?("something")
      ret.must_equal(true)
    end

    it "should be false on nil" do
      ret = repository.is_not_empty?(nil)
      ret.must_equal(false)
    end

    it "should be false on empty" do
      ret = repository.is_not_empty?("")
      ret.must_equal(false)
    end

  end

end