require "./src/common/validators/validator"
require "./src/common/validators/at_least_one_validator"
require "./src/common/validators/directory_exist_validator"
require "./src/common/validators/file_exist"
require "./src/common/validators/not_null_or_empty_validator"
require_relative "is_integer_validator"
require_relative "is_mode_validator"

module Batch
  module CommandLine
    class Validator

      def initialize(
          invalid_batch_size_validator = nil,
          is_mode_validator = nil,
          user_file_or_directory_validator = nil,
          deploy_file_or_directory_validator = nil,
          user_file_exist_validator = nil,
          deploy_file_exist_validator = nil
        )
        @invalid_batch_size_validator = invalid_batch_size_validator || IsIntegerValidator.new(lambda {|input| return input>=1}, "Batch size should be a number greater or equal to 1, but got:")
        @is_mode_validator = is_mode_validator || IsModeValidator.new()
        @user_file_or_directory_validator = user_file_or_directory_validator
        @deploy_file_or_directory_validator = deploy_file_or_directory_validator
        @user_file_exist_validator = user_file_exist_validator || Common::Validators::NotNullOrEmptyValidator.new("A User config file or directory is required")
        @deploy_file_exist_validator = deploy_file_exist_validator || Common::Validators::NotNullOrEmptyValidator.new("A Deploy config file or directory is required")
      end

      def execute(options)
        validators = [
          lambda { return @invalid_batch_size_validator.execute(options[:batch_size]) },
          lambda { return @is_mode_validator.execute(options[:mode]) },
          lambda { return @user_file_exist_validator.execute(options[:user_config]) },
          lambda { return @deploy_file_exist_validator.execute(options[:deploy_config]) }
        ]
        split_or_input(options[:user_config], ',').each do |user_config|
          validators.push(lambda { return get_user_config_validator(user_config).execute() } )
        end
        split_or_input(options[:deploy_config], ',').each do |deploy_config|
          validators.push(lambda { return get_deploy_config_validator(deploy_config).execute() } )
        end
        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

      def get_user_config_validator(user_config)
        unless @user_file_or_directory_validator.nil?
          return @user_file_or_directory_validator
        end
        return Common::Validators::AtLeastOneValidator.new([
          lambda { return Common::Validators::FileExist.new().execute(user_config) },
          lambda { return Common::Validators::DirectoryExistValidator.new().execute(user_config) }],
          "User config '#{user_config}' is NOT a file or directory"
          )
      end

      def get_deploy_config_validator(deploy_config)
        unless @deploy_file_or_directory_validator.nil?
          return @deploy_file_or_directory_validator
        end
        return Common::Validators::AtLeastOneValidator.new([
          lambda { return Common::Validators::FileExist.new().execute(deploy_config) },
          lambda { return Common::Validators::DirectoryExistValidator.new().execute(deploy_config) }],
          "Deploy config '#{deploy_config}' is NOT a file or directory"
          )
      end

      private
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
end