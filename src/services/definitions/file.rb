module Services
  module Definitions
    class File

      def initialize(destination_filepath, content)
        @destination_filepath = destination_filepath
        @content = content
      end

      def ==(other_file)
        return (other_file != nil && match_by_destination_filepath(other_file.get_destination_filepath()))
      end

      def match_by_destination_filepath(destination_filepath)
        return (destination_filepath != nil && @destination_filepath == destination_filepath)
      end

      def get_destination_filepath()
        return @destination_filepath
      end

      def get_content()
        return @content
      end

      def is_content_uri?()
        return @content!=nil && @content.start_with?("http")
      end

      def to_s()
        return "File destination_filepath:#{@destination_filepath} contentLength:#{(get_content() || "").length()}"
      end

    end
  end
end