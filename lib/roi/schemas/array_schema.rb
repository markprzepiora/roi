# typed: true
require 'roi/schemas/base_schema'

module Roi::Schemas
  class ArraySchema < BaseSchema
    def initialize
      super
      @unique = false
      @unique_remove_duplicates = false
      @items_schema = nil
      add_class_test(Array, "must be an Array")
      add_test('array.items', :items_test)
      add_test('array.unique', :uniqueness_test)
    end

    def items(schema)
      @items_schema = schema
      self
    end

    def nonempty
      must_not_be(:empty?)
    end

    def unique(remove_duplicates: false)
      @unique = true
      @unique_remove_duplicates = remove_duplicates
      self
    end

    private

    def items_test(array, context)
      return if !@items_schema

      results = array.map.with_index do |item, index|
        @items_schema.validate(item, context.add_path(index))
      end

      fails = results.reject(&:ok?)

      if fails.any?
        Fail(fails.map(&:errors).flatten(1))
      else
        Pass(results.map(&:value))
      end
    end

    def uniqueness_test(array, context)
      return if !@unique

      unique_element_count = Set.new(array).length

      if @unique_remove_duplicates && unique_element_count != array.length
        Pass(array.uniq)
      elsif unique_element_count != array.length
        Fail(context.error("elements must be unique"))
      end
    end

    def name
      'array'
    end
  end
end
