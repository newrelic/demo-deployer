require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/deployment/orchestrator"
require "./tests/context_builder.rb"

describe "Deployment::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:orchestrator) { Deployment::Orchestrator.new(context, validator) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do
    it "should return deployment provider" do
      ret = orchestrator.execute()
      assert_kind_of(Deployment::Provider, ret)
    end

    it "should call validator execute" do
      validator.expects(:execute).returns([])
      orchestrator.execute()
    end

    it "should raise exception" do
      validator.expects(:execute).returns(["error"])
      assert_raises Common::ValidationError do
        orchestrator.execute()
      end
    end
  end
end