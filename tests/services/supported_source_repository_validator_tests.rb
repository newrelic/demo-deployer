require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/services/supported_source_repository_validator"

describe "Service::PortValidator" do
  let(:services) { [] }
  let(:error) { "NOT WORKING" }
  let(:patterns) { [] }
  let(:validator) { Services::SupportedSourceRepositoryValidator.new(patterns, error) }

  it "should create validator" do
    validator.wont_be_nil
  end

  it "should NOT error when no source repository provided" do
    given_no_source_repository()
    validator.execute(services).must_be_nil()
  end
  
  it "should NOT error for supported repository" do
    given_pattern(".idk")
    given_source_repository("something@else.idk")
    validator.execute(services).must_be_nil()
  end
  
  it "should NOT error for 1 out of many patterns" do
    given_pattern(".idk")
    given_pattern(".git")
    given_pattern(".hg")
    given_source_repository("something@else.hg")
    validator.execute(services).must_be_nil()
  end
  
  it "should error for unsupported repository" do
    given_pattern(".idk")
    given_source_repository("this is not a repository")
    error = validator.execute(services)
    error.wont_be_nil()
    error.must_include(error)
    error.must_include(".idk")
  end
    
  it "should error for all supported patterns" do
    given_pattern(".idk")
    given_pattern(".git")
    given_pattern(".hg")
    given_source_repository("this is not a repository")
    error = validator.execute(services)
    error.wont_be_nil()
    error.must_include(error)
    error.must_include(".idk")
    error.must_include(".git")
    error.must_include(".hg")
  end

  def given_pattern(pattern)
    patterns.push(pattern)
  end

  def given_no_source_repository()
    services.push({"id" => 123})
  end

  def given_source_repository(source_repository)
    services.push({"source_repository"=> source_repository})
  end

end