#!/usr/bin/env ruby

require_relative './src/service/orchestrator'
require_relative './src/service/context'
require "./src/common/logger/logger_factory"

begin
  context = Service::Context.new()
  orchestrator = Service::Orchestrator.new(context)
  orchestrator.execute()
rescue Exception => e
  unless e.message.downcase() == "exit"
    Common::Logger::LoggerFactory.get_logger.error(e)
    Common::Logger::LoggerFactory.get_logger.error(e.backtrace)
    exit(1)
  end
end
exit(0)
