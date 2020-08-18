module Common
    module Text
      class FieldMergerFinder

        def initialize(*parts)
            @regExPattern = get_formated_key(parts)
        end

        def find(text)
            matches = []
            unless text.nil?
                matchData = text.scan(@regExPattern)
                matchData.each do |match|
                    match.each do |part|
                        matches.push(part)
                    end
                end
            end
            return matches
        end

        private
        def get_formated_key(parts)
            start = Regexp.new("\\[").to_s
            finish = Regexp.new("\\]").to_s
            replaced = []
            parts.each do |part|
                if part == "*"
                    replaced.push(".[^ ]+")
                else
                    replaced.push(part)
                end
            end
            all = replaced.join(":")
            complete = "(" +start +all +finish +")"
            return Regexp.new(complete)
        end

      end
    end
  end