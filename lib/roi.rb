require 'roi/version'
require 'roi/schemas/any_schema'
require 'roi/schemas/enum_schema'
require 'roi/schemas/boolean_schema'
require 'roi/schemas/string_schema'
require 'roi/schemas/int_schema'
require 'roi/schemas/number_schema'
require 'roi/schemas/object_schema'
require 'roi/schemas/array_schema'

module Roi
  # @example Match any non-nil value
  #   result = Roi.any.validate("Hello World!")
  #   result.ok? # => true
  #   result.value # => "Hello World!"
  #
  # @example Reject a nil value
  #   result = Roi.any.validate(nil)
  #   result.ok? # => false
  #   result.errors.first.message # => "must not be nil"
  #
  # @return [Schemas::AnySchema]
  def self.any
    Schemas::AnySchema.new
  end

  # @example Match only a specific list of values (passing)
  #   result = Roi.enum('stopped', 'running', 'failed').validate('stopped')
  #   result.ok? # => true
  #   result.value # => "stopped"
  #
  # @example Match only a specific list of values (failed)
  #   result = Roi.enum('stopped', 'running', 'failed').validate('STOPPED')
  #   result.ok? # => false
  #   result.errors.first.message # => must be one of #<Set: {"stopped", "running", "failed"}>
  #
  # @param *values [Array<Object>]
  # @return [Schemas::EnumSchema]
  def self.enum(*values)
    Schemas::EnumSchema.new.values(*values)
  end

  # @return [Schemas::BooleanSchema]
  def self.boolean
    Schemas::BooleanSchema.new
  end

  # @return [Schemas::StringSchema]
  def self.string
    Schemas::StringSchema.new
  end

  # @return [Schemas::IntSchema]
  def self.int
    Schemas::IntSchema.new
  end

  # @return [Schemas::NumberSchema]
  def self.number
    Schemas::NumberSchema.new
  end

  # @return [Schemas::ObjectSchema]
  def self.object
    Schemas::ObjectSchema.new
  end

  # @example Match any array of values
  #   result = Roi.array.validate([])
  #   result.ok? # => true
  #   result.value # => []
  #
  # @example Match an array of integers
  #   result = Roi.array.items(Roi.int).validate([1,2,3,4])
  #   result.ok? # => true
  #   result.value # => [1,2,3,4]
  #
  # @example Reject an array with an invalid element
  #   result = Roi.array.items(Roi.int).validate(['1', '2', '3', '4'])
  #   result.ok # => false
  #   result.errors.first
  #   # =>
  #   #     #<Roi::ValidationError:0x00007fffb916fab0
  #   #      @path=[0], @validator_name="int", @message="must be an Integer">
  #
  # @return [Schemas::ArraySchema]
  def self.array
    Schemas::ArraySchema.new
  end

  # You may define your schema using Roi.define. The given block will be
  # evaluated in the context of the Roi module, which means you may use
  # `string` instead of `Roi.string`, etc., in your schema definition. This
  # may make longer schemas much more readable!
  #
  # @example
  #   schema = Roi.define do
  #     object.keys({
  #       user_ids: array.items(int)
  #     })
  #   end
  #
  # @yieldreturn [Roi::Schemas::BaseSchema]
  def self.define(&block)
    instance_eval(&block)
  end
end
