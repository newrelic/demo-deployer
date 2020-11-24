require "fileutils"
require_relative "definitions/deployment"
require_relative "definitions/partition"

module Batch
  class Provider

    def initialize(context)
      @context = context
    end

    def get_all_deployments()
      @deployments ||= build_deployments()
      return @deployments
    end

    def get_all_partitions()
      @partitions ||= build_partitions(get_all_deployments())
      return @partitions
    end

    private
    def build_partitions(deployments)
      partitions = []
      deployments.each do |deployment|
        deployment_name = deployment.get_deployment_name()
        available_partition = (partitions).find() {|partition| partition.has_available_space?() && partition.has_deployment_name?(deployment_name) == false}
        if available_partition.nil?
          available_partition = Definitions::Partition.new((partitions.length+1), get_batch_size())
          partitions.push(available_partition)
        end
        available_partition.add_deployment(deployment)
      end
      return partitions
    end

    def build_deployments()
      deployments = []
      user_config_filenames = get_config_filenames(@context.get_command_line_provider().get_user_config_filepath())
      deploy_config_filenames = get_config_filenames(@context.get_command_line_provider().get_deploy_config_filepath())
      user_config_filenames.each do |user_config_filename|
        deploy_config_filenames.each do |deploy_config_filename|
          deployment = Definitions::Deployment.new(user_config_filename, deploy_config_filename)
          deployments.push(deployment)
        end
      end
      return deployments
    end

    def get_config_filenames(current, filenames = [])
      split_or_input(current, ',').each do |filename|
        if File.file?(filename)
          filenames.push(filename)
        else
          directory = filename.delete_suffix("/")
          if Dir.exist?(directory)
            Dir.children(directory).each do |item|
              if item.downcase().end_with?(".json")
                get_config_filenames(directory+"/" +item, filenames)
              end
            end
          end
        end
      end
      return filenames
    end

    def get_batch_size()
      return @batch_size ||= @context.get_command_line_provider().get_batch_size()
    end

    def split_or_input(input, delimiter)
      unless input.nil? 
        if input.include?(delimiter)
          return input.split(delimiter)
        end
        return [input]
      end
      return []
    end

  end
end