# typed: true
require 'roi'
require 'roi/validation_error'

module Roi
  class ValidationContext
    attr_reader :path
    attr_reader :validator_name

    def initialize(path: nil, validator_name: nil)
      @path = path || []
      @validator_name = validator_name
    end

    # @return [Roi::ValidationError]
    def error(message, validator_name: nil)
      validator_name ||= self.validator_name
      ValidationError.new(path: path, validator_name: validator_name, message: message)
    end

    # @return [Roi::ValidationContext]
    def add_path(*append_path)
      self.class.new(path: [*path, *append_path], validator_name: validator_name)
    end

    # @return [Roi::ValidationContext]
    def set_validator_name(validator_name)
      self.class.new(path: path, validator_name: validator_name)
    end
  end
end
