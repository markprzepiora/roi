require 'roi/schemas/base_schema'

module Roi::Schemas
  class ArraySchema < BaseSchema
    def initialize
      super
      add_test do |value, context|
        if !value.is_a?(Array)
          Fail([
            context.error(
              validator_name: name,
              message: 'must be an array',
            )
          ])
        end
      end

      add_test(&method(:items_test))
    end

    def name
      'array'
    end

    def items(schema)
      @items_schema = schema
      self
    end

    def nonempty
      must_not_be(:empty?)
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
      end
    end
  end
end
