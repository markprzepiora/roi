# typed: true

require 'roi/version'
require 'roi/schemas/any_schema'
require 'roi/schemas/enum_schema'
require 'roi/schemas/boolean_schema'
require 'roi/schemas/string_schema'
require 'roi/schemas/int_schema'
require 'roi/schemas/number_schema'
require 'roi/schemas/object_schema'
require 'roi/schemas/array_schema'
require 'sorbet-runtime'

module Roi
  extend T::Sig

  sig{ returns(Schemas::AnySchema) }
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

  sig{ params(values: T.untyped).returns(Schemas::EnumSchema) }
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
  # @param values [Array<Object>]
  # @return [Schemas::EnumSchema]
  def self.enum(*values)
    T.unsafe(Schemas::EnumSchema.new).values(*values)
  end

  sig{ returns(Schemas::BooleanSchema) }
  # @return [Schemas::BooleanSchema]
  def self.boolean
    Schemas::BooleanSchema.new
  end

  sig{ returns(Schemas::StringSchema) }
  # @return [Schemas::StringSchema]
  def self.string
    Schemas::StringSchema.new
  end

  sig{ returns(Schemas::IntSchema) }
  # @return [Schemas::IntSchema]
  def self.int
    Schemas::IntSchema.new
  end

  sig{ returns(Schemas::NumberSchema) }
  # @return [Schemas::NumberSchema]
  def self.number
    Schemas::NumberSchema.new
  end

  sig{ params(hash: T::Hash[T.any(String, Symbol), Roi::Schemas::BaseSchema]).returns(Schemas::ObjectSchema) }
  # Instantiate a new Object (Hash) schema.
  #
  # Can use the shorthand:
  #
  #     Roi.object(hash)
  #
  # For:
  #
  #     Roi.object.keys(hash)
  #
  # @param hash [Hash{Object => Roi::Schemas::BaseSchema}]
  # @return [Schemas::ObjectSchema]
  def self.object(hash = {})
    Schemas::ObjectSchema.new.keys(hash)
  end

  sig{ params(items_schema: T.nilable(Roi::Schemas::BaseSchema)).returns(Schemas::ArraySchema) }
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
  #   result.ok? # => false
  #   result.errors.first
  #   # =>
  #   #     #<Roi::ValidationError:0x00007fffb916fab0
  #   #      @path=[0], @validator_name="int", @message="must be an Integer">
  #
  # @example `Roi.array(schema)` is short for `Roi.array.items(schema)`
  #   result = Roi.array(Roi.string).validate(['1', '2'])
  #   result.ok? # => true
  #
  # @return [Schemas::ArraySchema]
  def self.array(items_schema = nil)
    Schemas::ArraySchema.new.items(items_schema)
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
