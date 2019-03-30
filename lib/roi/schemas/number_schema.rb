require 'roi/schemas/base_schema'

module Roi::Schemas
  class NumberSchema < BaseSchema
    def initialize
      super

      add_class_test(Numeric, "must be Numeric")

      add_test('number.min') do |value, context|
        if @min && value < @min
          Fail(context.error("must be >= #{@min}"))
        end
      end

      add_test('number.max') do |value, context|
        if @max && value > @max
          Fail(context.error("must be <= #{@max}"))
        end
      end
    end

    def min(min)
      @min = min
      self
    end

    def max(max)
      @max = max
      self
    end

    private

    def name
      'int'
    end
  end
end
