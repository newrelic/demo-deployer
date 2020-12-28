module Common
  module Install
    class Params

      def initialize()
        @params = {}
      end

      def get_all()
        return @params.clone()
      end

      def get(key)
        if @params.key?(key)
          return @params[key]
        end
        return nil
      end

      def add(key, value)
        if @params.key?(key)
          if @params[key] != value
            message = "key #{key} is already defined in the params collection, adding #{value} would overwrite the previous value of #{@params[key]}"
            raise message
          end
        end
        @params[key] = value
      end

      def update(key, value)
        if @params.key?(key)
          @params[key] = value
        else
          add(key, value)
        end
      end

      def to_s()
        return "Params:#{@params}"
      end

    end
  end
end
