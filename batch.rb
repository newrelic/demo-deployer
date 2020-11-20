#!/usr/bin/env ruby

require_relative 'src/batch/orchestrator'
require_relative 'src/batch/context'
require "./src/common/logger/logger_factory"

begin
  context = Batch::Context.new()
  orchestrator = Batch::Orchestrator.new(context)
  orchestrator.execute()
rescue Exception => e
  unless e.message.downcase() == "exit"
    Common::Logger::LoggerFactory.get_logger.error(e)
    Common::Logger::LoggerFactory.get_logger.error(e.backtrace)
    exit(1)
  end
end
