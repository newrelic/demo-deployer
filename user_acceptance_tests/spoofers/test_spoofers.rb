require 'minitest'

module UserAcceptanceTests
  module Spoofers
    class TestSpoofers

      def initialize(items = [])
        @items = items
      end

      def add(item)
        @items.push(item)
      end

      def dispose()
        @items.each do |item| 
          begin
            item.dispose()             
          rescue => exception
            puts "Error while tearing down spoofer #{item}, reason: #{exception}"
          end
        end
      end

    end
  end
end