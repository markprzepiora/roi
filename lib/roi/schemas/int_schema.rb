require 'roi/schemas/base_schema'

module Roi::Schemas
  class IntSchema < BaseSchema
    def initialize
      super

      add_test(name, :test_int)
      add_test("#{name}.min", :test_min)
      add_test("#{name}.max", :test_max)
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

    def test_int(value, context)
      respond_to_to_i = value.respond_to?(:to_i)
      value_to_i = respond_to_to_i && value.to_i

      if respond_to_to_i && value_to_i == value && value_to_i.is_a?(Integer)
        Pass(value_to_i)
      else
        Fail(context.error('must be an Integer'))
      end
    end

    def test_min(value, context)
      if @min && value < @min
        Fail(context.error("must be >= #{@min}"))
      end
    end

    def test_max(value, context)
      if @max && value > @max
        Fail(context.error("must be <= #{@max}"))
      end
    end

    def cast_value(value, context)
      Pass(Integer(value))
    rescue ArgumentError, TypeError => e
      Fail(context.error("cannot be cast to an Integer"))
    end

    def name
      'int'
    end
  end
end
