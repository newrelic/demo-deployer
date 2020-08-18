require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/app_config/orchestrator"
require "./tests/context_builder.rb"

describe "AppConfig::Orchestrator" do
  let(:file) { {"file": {}}}
  let(:context){ Tests::ContextBuilder.new().build() }
  let(:validator) { m = mock(); m.stubs(:execute).returns([]); m }
  let(:merge_files) { m = mock(); m.stubs(:execute).returns({}); m }
  let(:yaml_fileLoader) { m = mock(); m.stubs(:new).returns(file); m }
  let(:orchestrator) { AppConfig::Orchestrator.new(context, validator, merge_files) }  

  it "should create orchestrator" do
    orchestrator.wont_be_nil
  end

  describe "execute" do
    it "should return app_config provider" do
      ret = orchestrator.execute()
      assert_kind_of(AppConfig::Provider, ret)
    end

    it "should call get_default" do
      orchestrator.expects(:get_default)
      orchestrator.execute()
    end

    it "should call get_override" do
      orchestrator.expects(:get_override)
      orchestrator.execute()
    end

    it "should call merge_files" do
      merge_files.expects(:execute)
      orchestrator.execute()
    end

    it "should call validator execute" do
      validator.expects(:execute).returns([])
      orchestrator.execute()
    end

    it "should raise exception" do
      validator.expects(:execute).returns(["error1"])
      assert_raises Common::ValidationError do
        orchestrator.execute()
      end
    end

  end
end