require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/command_line/orchestrator"
require "./tests/context_builder.rb"

describe "Commandline::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new().build() } 
  let(:orchestrator) { CommandLine::Orchestrator.new(context) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do
    let(:parser) { m = mock(); m.stubs(:execute).returns({}); m }
    let(:validator) { m = mock(); m.stubs(:execute).returns({}); m }
    let(:orchestrator) { CommandLine::Orchestrator.new(context, parser, validator) }
    let(:args) { ['-h'] }

    it "should return command line provider" do
      ret = orchestrator.execute(args)
      assert_kind_of(CommandLine::Provider, ret)
    end

    it "should call parser execute" do
      parser.expects(:execute)
      ret = orchestrator.execute(args)
    end

    it "should call validator execute" do
      validator.expects(:execute).returns([])
      ret = orchestrator.execute(args)
    end

    it "should raise exception" do
      validator.expects(:execute).returns([''])
      assert_raises Common::ValidationError do
        orchestrator.execute(args)
      end
    end

  end
end