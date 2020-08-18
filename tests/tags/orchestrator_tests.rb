require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/tags/orchestrator"
require "./src/tags/parsed_output"
require "./src/common/logger/logger"
require "./tests/context_builder"

describe "Tags::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:global_tags) { {} }
  let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:parsed_output) { Tags::ParsedOutput.new({}, {}, {}) }
  let(:parser) { m = mock(); m.stubs(:execute).returns(parsed_output); m }
  let(:orchestrator) { Tags::Orchestrator.new(context, parser, validator) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do
    it "should return tags provider" do
      ret = orchestrator.execute({})
      assert_kind_of(Tags::Provider, ret)
    end

    it "should call validator execute" do
      validator.expects(:execute).returns([])
      orchestrator.execute({})
    end

    it "should raise exception" do
      validator.expects(:execute).returns(["ERROR"])
      assert_raises Common::ValidationError do
        orchestrator.execute({})
      end
    end
  end

end