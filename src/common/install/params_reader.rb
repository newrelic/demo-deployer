require "./src/common/logger/logger_factory"

module Common
  module Install
    class ParamsReader

      def initialize(params)
        @params = params
      end

      def read_from_file(filename)
        errors = []
        begin
          Common::Logger::LoggerFactory.get_logger().debug("ParamsReader, reading from file #{filename}")
          file_content = File.read(filename)
          read_from_json(file_content)
        rescue Errno::ENOENT => e
          raise Common::ValidationError.new("Could not read file #{filename}: #{e}.")
        end
      end

      def read_from_json(file_content)
        content = {}
        begin
          content = JSON.parse(file_content)
        rescue JSON::ParserError => e
          raise Common::ValidationError.new("Could not read a valid JSON: #{e}.")
        end
        # if content.key?("params")
        #   content["params"].each do |key,value|
        #     Common::Logger::LoggerFactory.get_logger().debug("ParamsReader, reading key #{key} with value #{value}")
        #     @params.add(key, value)
        #   end
        # end
      end

    end
  end
end