module Teardown
  class Summary

    def execute()
      summary = "Teardown successful!\n\n"
      Common::Logger::LoggerFactory.get_logger.info(summary)
      return summary
    end

  end
end