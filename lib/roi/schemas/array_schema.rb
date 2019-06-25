# typed: true
require 'roi/schemas/base_schema'

module Roi::Schemas
  class ArraySchema < BaseSchema
    sig{ void }
    def initialize
      super
      @unique = false
      @unique_remove_duplicates = false
      @items_schema = nil
      add_class_test(Array, "must be an Array")
      add_test('array.items', :items_test)
      add_test('array.unique', :uniqueness_test)
    end

    sig{
      params(schema: T.nilable(Roi::Schemas::BaseSchema)).
      returns(Roi::Schemas::ArraySchema)
    }
    def items(schema)
      @items_schema = schema
      self
    end

    sig{ returns(Roi::Schemas::ArraySchema) }
    def nonempty
      must_not_be(:empty?)
    end

    sig{ params(remove_duplicates: T::Boolean).returns(Roi::Schemas::ArraySchema) }
    def unique(remove_duplicates: false)
      @unique = true
      @unique_remove_duplicates = remove_duplicates
      self
    end

    private

    sig{
      params(array: T::Array[T.untyped], context: Roi::ValidationContext).
      returns(T.nilable(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail)))
    }
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

    sig{
      params(array: T::Array[T.untyped], context: Roi::ValidationContext).
      returns(T.nilable(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail)))
    }
    def uniqueness_test(array, context)
      return if !@unique

      unique_element_count = Set.new(array).length

      if @unique_remove_duplicates && unique_element_count != array.length
        Pass(array.uniq)
      elsif unique_element_count != array.length
        Fail(context.error("elements must be unique"))
      end
    end

    sig{ returns String }
    def name
      'array'
    end
  end
end
