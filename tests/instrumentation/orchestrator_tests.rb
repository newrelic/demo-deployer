require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/instrumentation/orchestrator"
require "./src/common/validation_error"
require "./tests/context_builder.rb"

describe "Instrumentation::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new().build() } 
  let(:parser) { m = mock(); m.stubs(:get).returns({}); m }
  let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:git_proxy) { m = mock(); m.stubs(:clone).returns(""); m }
  let(:orchestrator) { Instrumentation::Orchestrator.new(context, parser, validator, git_proxy) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do

    it "should return instrumentation provider" do
      ret = orchestrator.execute({})
      assert_kind_of(Instrumentation::Provider, ret)
    end

    it "should call parser execute" do
      orchestrator.execute({})
    end

    it "should call validator execute" do
      validator.expects(:execute).returns([])
      ret = orchestrator.execute({})
    end

    it "should raise exception" do
      validator.expects(:execute).returns(["Error"])
      assert_raises Common::ValidationError do
        orchestrator.execute({})
      end
    end
  end
end
