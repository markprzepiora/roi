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
  # @return [Schemas::AnySchema]
  def self.any
    Schemas::AnySchema.new
  end

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

  # @return [Schemas::ArraySchema]
  def self.array
    Schemas::ArraySchema.new
  end
end
