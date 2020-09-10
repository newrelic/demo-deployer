require "./src/common/install/params"

module Instrumentation
  module Definitions
    class Instrumentor

      def initialize (id, item_id, provider, version, deploy_script_path, source_path)
        @id = id
        @item_id = item_id
        @provider = provider
        @version = version
        @deploy_script_path = deploy_script_path
        @source_path = source_path
        @params = Common::Install::Params.new()
        @provider_credential = nil
      end

      def get_id()
        return @id
      end

      def get_item_id()
        return @item_id
      end

      def get_provider()
        return @provider
      end

      def get_version()
        return @version
      end

      def get_deploy_script_path()
        return @deploy_script_path
      end

      def get_source_path()
        return @source_path
      end

      def get_deploy_script_full_path()
        return Common::Io::DirectoryService.combine_paths(@source_path, @deploy_script_path)
      end

      def get_params()
        return @params
      end

      def get_provider_credential()
        return @provider_credential
      end
      def set_provider_credential(credential)
        @provider_credential = credential
      end

      protected
      def match_by_identity(identity)
        return (identity != nil && get_identity() == identity)
      end

    end
  end
end
