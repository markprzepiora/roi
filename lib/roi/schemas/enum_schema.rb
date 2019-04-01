require 'roi/schemas/base_schema'
require 'set'

module Roi::Schemas
  class EnumSchema < BaseSchema
    def initialize
      super
      @valid_values = Set.new
      add_test('enum.values', :test_values)
    end

    def values(*valid_values)
      @valid_values.merge(valid_values)
      self
    end

    private

    def name
      'enum'
    end

    def test_values(value, context)
      if !@valid_values.include?(value)
        Fail(context.error("must be one of #{@valid_values.inspect}"))
      end
    end
  end
end
