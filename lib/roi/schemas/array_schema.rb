require 'roi/schemas/base_schema'

module Roi::Schemas
  class ArraySchema < BaseSchema
    def initialize
      super
      @unique = false
      add_class_test(Array, "must be an Array")
      add_test(&method(:items_test))
      add_test(&method(:uniqueness_test))
    end

    def items(schema)
      @items_schema = schema
      self
    end

    def nonempty
      must_not_be(:empty?)
    end

    def unique
      @unique = true
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

      if Set.new(array).length != array.length
        Fail(context.error(validator_name: "#{name}.unique", message: "elements must be unique"))
      end
    end

    def name
      'array'
    end
  end
end
