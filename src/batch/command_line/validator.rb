require "./src/common/validators/validator"
require "./src/common/validators/at_least_one_validator"
require "./src/common/validators/directory_exist_validator"
require "./src/common/validators/file_exist"
require_relative "is_integer_validator"
require_relative "is_mode_validator"

module Batch
  module CommandLine
    class Validator

      def initialize(
          invalid_batch_size_validator = nil,
          is_mode_validator = nil,
          user_file_or_directory_validator = nil,
          deploy_file_or_directory_validator = nil
        )
        @invalid_batch_size_validator = invalid_batch_size_validator || IsIntegerValidator.new(lambda {|input| return input>=1}, "Number should be greater or equal to 1, but got:")
        @is_mode_validator = is_mode_validator || IsModeValidator.new()
        @user_file_or_directory_validator = user_file_or_directory_validator
        @deploy_file_or_directory_validator = deploy_file_or_directory_validator
      end

      def execute(options)
        validators = [
          lambda { return @invalid_batch_size_validator.execute(options[:batch_size]) },
          lambda { return @is_mode_validator.execute(options[:mode]) }
        ]
        validators.push(lambda { return get_user_config_validator(options[:user_config]).execute() } )
        validators.push(lambda { return get_deploy_config_validator(options[:deploy_config]).execute() } )
        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

      def get_user_config_validator(user_config)
        return @user_file_or_directory_validator ||= Common::Validators::AtLeastOneValidator.new([
          lambda { return Common::Validators::FileExist.new().execute(user_config) },
          lambda { return Common::Validators::DirectoryExistValidator.new().execute(user_config) }],
          "User config '#{user_config}' is NOT a file or directory"
          )
      end

      def get_deploy_config_validator(deploy_config)
        return @deploy_file_or_directory_validator ||= Common::Validators::AtLeastOneValidator.new([
          lambda { return Common::Validators::FileExist.new().execute(deploy_config) },
          lambda { return Common::Validators::DirectoryExistValidator.new().execute(deploy_config) }],
          "Deploy config '#{deploy_config}' is NOT a file or directory"
          )
      end

    end
  end
end