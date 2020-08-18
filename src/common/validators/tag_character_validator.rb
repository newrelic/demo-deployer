module Common
  module Validators
    class TagCharacterValidator

      def initialize(regex = nil)
        @regex = regex || /\A[a-zA-Z0-9_\-\:]*\z/
      end

      def execute(tags)
        errors = []
        (tags || []).each do |k, v|
          unless is_valid(k)
            errors.push("#{k}:#{v}")
          end
        end
        unless errors.empty?
          return errors.compact()
        end
        return errors
      end

      private
      def is_valid(string)
        if (string || "").match(@regex).nil?
          return false
        end
        return true
      end

    end
  end
end

