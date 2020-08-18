require "json"
require "./src/common/io/directory_service"
require "./src/common/install/params"

module Services
  module Definitions
    class Service

      def initialize(id, display_name, port, destinations, source_path, deploy_script_path, relationships, endpoints = nil, deploy_host = nil, provider_credential=nil)
        @id = id.downcase
        @display_name = display_name || @id
        @port = port
        @source_path = source_path
        @deploy_script_path = deploy_script_path
        @relationships = relationships
        @endpoints = endpoints
        unless destinations.nil?
          @destinations = destinations.map(&:downcase)
        else
          @destinations = []
        end
        @deploy_host = deploy_host
        @provider_credential = provider_credential
        @params = Common::Install::Params.new()
        @files = []
        @tags = {}
      end

      def add_tags(tags)
        @tags = @tags.merge(tags)
      end

      def get_tags()
        return @tags
      end

      def ==(other_resource)
        return (other_resource != nil && match_by_id(other_resource.get_id()))
      end

      def match_by_id(id)
        # change the comparison with .downcase to .casecmp? if we pin
        # ruby version > 2.4
        return (id != nil && @id == id.downcase)
      end

      def get_id()
        return @id
      end

      def get_display_name()
        return @display_name
      end

      def get_port()
        return @port
      end

      def get_destinations()
        return @destinations
      end

      def get_source_path()
        return @source_path
      end

      def get_deploy_script_full_path()
        return Common::Io::DirectoryService.combine_paths(@source_path, @deploy_script_path)
      end

      def get_relationships()
        return @relationships
      end

      def get_endpoints()
        return @endpoints
      end

      def get_deploy_host()
        return @deploy_host
      end

      def get_provider_credential()
        return @provider_credential
      end

      def get_params()
        return @params
      end

      def get_files()
        return @files
      end

      def add_files(files)
        (files || []).each do |file|
          @files.push(file)
        end
      end

      def to_s()
        return "Service id:#{@id} port:#{@port} destinations:#{@destinations} source_path:#{@source_path} deploy_script_path:#{@deploy_script_path} relationships:#{@relationships} endpoints:#{@endpoints} deploy_host:#{@deploy_host} filesLength:#{get_files().length()}"
      end

    end
  end
end