require 'roi'
require 'roi/validation_error'

module Roi
  class ValidationContext
    attr_reader :path

    def initialize(path:)
      @path = path || []
    end

    # @return [Roi::ValidationError]
    def error(validator_name:, message:)
      ValidationError.new(path: path, validator_name: validator_name, message: message)
    end

    # @return [Roi::ValidationContext]
    def add_path(*append_path)
      self.class.new(path: [*path, *append_path])
    end
  end
end
