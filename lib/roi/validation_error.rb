# typed: true
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

    # The path to the error on the input object. The idea is that you should be
    # able to call `#dig` on the input object (if it is a Hash or Array) with
    # the path components returned here to retrieve the rejected value.
    #
    # @example
    #   schema = Roi.object.keys(users: Roi.array.items(Roi.string))
    #   hash = { users: ['Amy', :BOB, 'Charles'] }
    #   result = schema.validate(hash)
    #   result.errors.first.path # => [:users, 1]
    #   hash.dig(*result.errors.first.path) # => :BOB
    #
    # @return [Array<String, Symbol, Integer>]
    attr_reader :path

    # @return [String]
    attr_reader :validator_name

    # @example
    #   "must be a String"
    #
    # @return [String]
    attr_reader :message

    def initialize(path: nil, validator_name: nil, message: nil)
      @path = path
      @validator_name = validator_name
      @message = message
    end
  end
end
