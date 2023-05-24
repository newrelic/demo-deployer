require "./src/common/validators/file_exist"
require "./src/common/validators/validator"

module UserConfig
    module Validators
        module Aws
            class ApiKeyValidator

                def initialize(error_message = nil)
                    @error_message = error_message || "Invalid AWS API key"
                end

                def execute(aws_configs)
                    apiKey = getField(aws_configs, "apiKey")
                    sessionToken = getField(aws_configs, "sessionToken")
                    if (apiKey || "").start_with?("AKIA")
                        unless (sessionToken || "").empty?
                            return "#{@error_message}: a session token exist but API key AKIA... is not compatible with session tokens"
                        end
                    end
                    if (apiKey || "").start_with?("ASIA")
                        if (sessionToken || "").empty?
                            return "#{@error_message}: a session token does not exist but API key ASIA... is defined for session tokens"
                        end
                    end
                    return nil
                end

                def getField(configs, field_name)
                    (configs || []).each do |config|
                        unless (config[field_name.to_sym] || "").empty?
                            return config[field_name.to_sym]
                        end
                        unless (config[field_name] || "").empty?
                            return config[field_name]
                        end
                        return ""
                    end
                end
            end
        end
    end
end