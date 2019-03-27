require 'roi/version'
require 'roi/schemas/any_schema'
require 'roi/schemas/string_schema'
require 'roi/schemas/int_schema'
require 'roi/schemas/object_schema'
require 'roi/schemas/array_schema'

module Roi
  def self.any
    Schemas::AnySchema.new
  end

  def self.string
    Schemas::StringSchema.new
  end

  def self.int
    Schemas::IntSchema.new
  end

  def self.object
    Schemas::ObjectSchema.new
  end

  def self.array
    Schemas::ArraySchema.new
  end
end
