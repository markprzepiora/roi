require 'roi'
require 'roi/validation_error'

module Roi
  class ValidationContext
    attr_reader :path, :parent

    def initialize(path:, parent:)
      @path = path || []
      @parent = nil
    end

    def key
      path.last
    end

    def error(validator_name:, message:)
      ValidationError.new(path: path, validator_name: validator_name, message: message)
    end

    def add_path(*append_path)
      self.class.new(path: [*path, *append_path], parent: parent)
    end

    def set_parent(new_parent)
      self.class.new(path: path, parent: new_parent)
    end
  end
end
