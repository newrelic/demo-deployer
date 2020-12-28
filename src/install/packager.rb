require "fileutils"
require 'open-uri'
require "./src/common/logger/logger_factory"
require "./src/common/io/directory_service"
require "./src/install/service_field_merger_builder"

module Install
  class Packager
    def initialize(context,
                  execution_path,
                  service_field_merger_builder = nil)
      @context = context
      @execution_path = execution_path
      @service_field_merger_builder = service_field_merger_builder || Install::ServiceFieldMergerBuilder.new()
    end

    def execute()
      field_merger = get_field_merger()
      get_services().each do |service|
        service_id = service.get_id()
        Common::Logger::LoggerFactory.get_logger().debug("Packaging service #{service_id}")
        service_path = service.get_source_path()

        params = service.get_params()
        params.get_all().each do | key, value |
          merged_value = field_merger.merge(value)
          params.update(key, merged_value) 
        end

        service.get_files().each do |file|
          destination_filepath = file.get_destination_filepath()
          content = file.get_content()
          filepath = Common::Io::DirectoryService.combine_paths(service_path, destination_filepath)
          ensure_destination_sub_directory_exist(service_path, destination_filepath)
          file_permission = file.is_executable() ? 0755 : nil

          if File.exist?(filepath)
            Common::Logger::LoggerFactory.get_logger().debug("Deleting existing file #{filepath}")
            File.delete(filepath)
          end

          merged_content = field_merger.merge(content)
          if file.is_content_uri?()
            Common::Logger::LoggerFactory.get_logger().debug("Downloading from #{merged_content} to file #{filepath}")
            download = open(merged_content).read()
            merged_download = field_merger.merge(download)
            write_file(filepath, merged_download, file_permission)
          else
            Common::Logger::LoggerFactory.get_logger().debug("Writing content file #{filepath}")
            write_file(filepath, merged_content, file_permission)
          end
        end
      end
    end

    private
    def ensure_destination_sub_directory_exist(service_path, destination_filepath)
      if destination_filepath.include?("/")
        subdirectories = destination_filepath.split("/")
        subdirectories.pop()
        destination_directory = subdirectories.join("/")
        unless Dir.exist?("#{service_path}/#{destination_directory}")
          Common::Logger::LoggerFactory.get_logger().debug("Creating directory #{service_path}/#{destination_directory}")
          directoryService = Common::Io::DirectoryService.new(service_path)
          directoryService.create_sub_directory(destination_directory)
        end
      end
    end

    def write_file(filepath, content, permission)
      if permission.nil?
        File.open(filepath, mode="w") do |stream|
          stream.write(content)
        end
      else
        File.open(filepath, mode="w", perm=permission) do |stream|
          stream.write(content)
        end
      end
    end

    def get_services()
      return @context.get_services_provider().get_services()
    end

    def get_field_merger()
      @field_merger ||= build_service_field_merger()
      return @field_merger
    end

    def build_service_field_merger()
      services = get_services()
      provisioned_resources = @context.get_provision_provider().get_all()
      field_merger = @service_field_merger_builder
        .with_services(services, provisioned_resources)
        .with_user_credentials(@context)
        .with_app_config(@context)
        .build()
      return field_merger
    end

    def get_execution_path()
      return @execution_path
    end

  end
end
