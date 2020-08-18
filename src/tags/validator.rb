require "./src/common/validators/validator"
require "./src/common/validators/tag_character_validator"
require "./src/common/validators/key_value_max_length_validator"

module Tags
  class Validator

    def initialize(     
        tag_character_validator = Common::Validators::TagCharacterValidator.new(),
        tag_length_validator = Common::Validators::KeyValueMaxLengthValidator.new(128, 256, "The following tag key or values are too long:")
    )
      @tag_character_validator = tag_character_validator
      @tag_length_validator = tag_length_validator
    end

    def execute(tags)
      validators = [
          lambda { return @tag_character_validator.execute(tags) },
          lambda { return @tag_length_validator.execute(tags) }
      ]
      validator = Common::Validators::Validator.new(validators)

      return validator.execute()
    end

  end
end

