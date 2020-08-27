require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/ansible/player"
require "./src/common/logger/logger_factory"

describe "Common::Ansible::Player" do
    let(:output_content)
    let(:player) { Common::Ansible::Player.new() }

    before do
        given_logger()
    end
    
    it "should fail when unreachable" do
        player.has_ansible_succeeded?(true, " something is unreachable=1 for sure", "/path1").must_equal(false)
    end

    it "should fail when unreachable and process failed" do
        player.has_ansible_succeeded?(false, " something is unreachable=1 for sure", "/path1").must_equal(false)
    end

    it "should NOT fail when NOT unreachable" do
        player.has_ansible_succeeded?(true, " something is good and unreachable=0 .", "/path1").must_equal(true)
    end

    it "should fail when failed" do
        player.has_ansible_succeeded?(true, " something is failed=1 for sure", "/path1").must_equal(false)
    end

    it "should NOT fail when NOT failed" do
        player.has_ansible_succeeded?(true, " something is good and failed=0 .", "/path1").must_equal(true)
    end

    it "should NOT fail when succeeded" do
        player.has_ansible_succeeded?(false, " no issue here because unreachable=0 and failed=0 .", "/path1").must_equal(true)
    end

    it "should fail when really failed" do
        player.has_ansible_succeeded?(false, " something is not good because failed=1 .", "/path1").must_equal(false)
    end

    def given_logger()
        logger = mock()
        Common::Logger::LoggerFactory.stubs(:get_logger).returns(logger)
        logger.stubs(:debug)
        logger.stubs(:info)
        logger.stubs(:error)
    end
end