require "minitest/spec"
require "minitest/autorun"
require "mocha/minitest"

require "./src/common/logger/logger_factory"
require "./src/common/logger/info_logger"
require "./src/common/logger/debug_logger"
require "./src/common/logger/error_logger"

describe "Common::Logger::LoggerFactory" do

  it "should create a DebugLogger object" do
    given_logger("debug")
    logger = Common::Logger::LoggerFactory.get_logger()
    logger.must_be_instance_of(Common::Logger::DebugLogger)
  end

  it "should create a ErrorLogger object" do
    given_logger("error")
    logger = Common::Logger::LoggerFactory.get_logger()
    logger.must_be_instance_of(Common::Logger::ErrorLogger)
  end

  it "should create an InfoLogger object" do
    given_logger("info")
    logger = Common::Logger::LoggerFactory.get_logger()
    logger.must_be_instance_of(Common::Logger::InfoLogger)
  end

  def given_logger(logging_level)
    Common::Logger::LoggerFactory.set_logging_level(logging_level)
    Common::Logger::LoggerFactory.set_execution_type("Test")
  end

end
