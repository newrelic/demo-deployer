module Common
  module Text
    class FieldMerger

      def initialize(definitions = nil, env_lambda = nil)
        @definitions = definitions || Hash.new()
        @env_lambda = env_lambda || lambda { |name| return ENV[name] }
        @matches = {}
        @finders = []
      end

      def add_finder(finder)
        @finders.push(finder)
      end

      def get_definitions()
        return @definitions.merge({})
      end

      def merge_values(dictionary)
        result = {}
        (dictionary || {}).each do |key,value|
          result[key] = merge(value)
        end
        return result
      end

      def merge(text)
        @matches = {}
        unless text.nil?
          @definitions.each do |key, value|
            continue = true
            while continue
              continue = false
              if text.kind_of?(String) && key.include?("[env:*]") && text.include?("[env:")
                env_var_name = get_matching_env_or_nil(text)
                unless env_var_name.nil?
                  newKey = "[env:#{env_var_name}]"
                  newValue = @env_lambda.call(env_var_name)
                  text = replace_text(text, newKey, newValue)
                  continue = true
                  next
                end
              end
              text = replace_text(text, key, value)
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

        def replace_text(text, key, value)
          if text.kind_of?(String) && text.include?(key) && value.nil? == false
            addMatch(key, value)
            text = text.gsub(key, value)
          end
          return text
        end

        def get_matching_env_or_nil(value)
          env_regex = /\[(?i)env\:(\w+)\]/
          matches = env_regex.match(value)
          unless matches.nil?
            captures = matches.captures
            if captures.length > 0
              return captures[0]
            end
          end
          return nil
        end

    end
  end
end
