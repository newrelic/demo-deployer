require "minitest/spec"
require "minitest/autorun"
require 'mocha/minitest'

require "./src/user_config/orchestrator"
require "./tests/context_builder.rb"

describe "UserConfig" do
  describe "Orchestrator" do
    let(:context){ Tests::ContextBuilder.new().user_config().with_aws().build() }
    let(:parser) { m = mock(); m.stubs(:execute).returns({}); m }
    let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
    let(:orchestrator) { UserConfig::Orchestrator.new(context, parser, validator) }

    it "should create orchestrator" do
      orchestrator.wont_be_nil
    end

    describe "execute" do

      it "should return user_config provider" do
        ret = orchestrator.execute({})
        assert_kind_of(UserConfig::Provider, ret)
      end

      it "should call parser.execute" do
        parser.expects(:execute)
        orchestrator.execute({})
      end

      it "should call validator execute" do
        validator.expects(:execute).returns([])
        orchestrator.execute({})
      end

      it "should raise exception" do
        validator.expects(:execute).returns(["error1"])
        assert_raises Common::ValidationError do
          orchestrator.execute({})
        end
      end
    end

  end
end 
