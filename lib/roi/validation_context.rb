require 'roi'
require 'roi/validation_error'

module Roi
  class ValidationContext
    attr_reader :path, :parent

    def initialize(path:, parent:)
      @path = path || []
      @parent = nil
    end

    # @return [Roi::ValidationError]
    def error(validator_name:, message:)
      ValidationError.new(path: path, validator_name: validator_name, message: message)
    end

    # @return [Roi::ValidationContext]
    def add_path(*append_path)
      self.class.new(path: [*path, *append_path], parent: parent)
    end
  end
end
