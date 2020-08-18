require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/services/orchestrator"
require "./tests/context_builder.rb"

describe "Services::Orchestrator" do
  let(:context){ Tests::ContextBuilder.new()
    .user_config().with_aws()
    .build() }
  let(:parser) { m = mock(); m.stubs(:get_children).returns({}); m }
  let(:git_proxy) { m = mock(); m.stubs(:clone).returns(""); m }
  let(:directory_copier) { m = mock(); m.stubs(:copy).returns(""); m }
  let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:get_source_paths_file) { m = mock(); m.stubs(:execute).returns({}); m }
  let(:orchestrator) { Services::Orchestrator.new(context, parser, validator, git_proxy, directory_copier) }

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do

    it "should return command line provider" do
      orchestrator.expects(:get_source_paths_file).returns({})
      ret = orchestrator.execute({})
      assert_kind_of(Services::Provider, ret)
    end

    it "should call parser" do
      parser.expects(:get_children)
      orchestrator.stubs(:get_source_paths_file).returns({})
      orchestrator.execute({})
    end

    it "should call validator execute" do
      orchestrator.expects(:get_source_paths_file).returns({})
      validator.expects(:execute).returns([])
      orchestrator.execute({})
    end

    it "should call get_source_paths_file" do
      orchestrator.expects(:get_source_paths_file).returns({})
      orchestrator.execute({})
    end

    it "should call raise error" do
      validator.expects(:execute).returns(["error1"])
      assert_raises Common::ValidationError do
        orchestrator.execute({})
      end
    end

  end

end