require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/infrastructure/orchestrator"
require "./src/common/validation_error"
require "./tests/context_builder.rb"

describe "Infrastructure::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:config) { {} }
  let(:parser) { m = mock(); m.stubs(:get_children).returns({}); m }
  let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:orchestrator) { Infrastructure::Orchestrator.new(context, parser, validator) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do

    it "should return Infrastructure provider" do
      ret = orchestrator.execute(config)
      assert_kind_of(Infrastructure::Provider, ret)
    end

    it "should call parser" do
      parser.expects(:get_children)
      orchestrator.execute(config)
    end

    it "should call validator execute" do
      validator.expects(:execute).returns([])
      ret = orchestrator.execute(config)
    end

    it "should raise exception" do
      validator.expects(:execute).returns(["Error"])
      assert_raises Common::ValidationError do
        orchestrator.execute(config)
      end
    end
  end
end
