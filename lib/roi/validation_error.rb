require 'roi'

module Roi
  class ValidationError
    # Examples:
    #
    #     path => ['users', 2, 'name']
    #     validator_name => 'string'
    #     message => 'must be a string'
    #
    #     path => ['age']
    #     validator_name => 'int.min'
    #     message => 'must be at least 21'
    attr_reader :path
    attr_reader :validator_name
    attr_reader :message

    def initialize(path:, validator_name:, message:)
      @path = path
      @validator_name = validator_name
      @message = message
    end
  end
end
