module Common
  module Text
    class FieldMerger

      def initialize(definitions = nil)
        @definitions = definitions || Hash.new()
        @matches = {}
        @finders = []
      end

      def add_finder(finder)
        @finders.push(finder)
      end

      def merge(text)
        @matches = {}
        unless text.nil?
          @definitions.each do |key, value|
            if text.include?(key)
              addMatch(key, value)
              text = text.gsub(key, value)
            end
          end
        end
        @finders.each do |finder|
          found = finder.find(text)
          if found.size()>0
            allFound = found.join(",")
            raise Common::ValidationError.new("The following fields have no match:#{allFound}")
          end
        end
        return text
      end

      def eval(text)
        @matches = {}
        unless text.nil?
          @definitions.each do |key, value|
            if text.include?(key)
              addMatch(key, value)
            end
          end
        end
        return @matches
      end

      def get_definitions_key()
        keys = []
        @definitions.each do |key, value|
          keys.push(key)
        end
        return keys
      end

      def get_matches()
        return @matches
      end

      private
        def addMatch(key, value)
          @matches[key] = value
          keys = @matches["keys"] || []
          keys.push(key)
          @matches["keys"] = keys
        end

    end
  end
end