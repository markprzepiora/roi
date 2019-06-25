# typed: true
require 'roi/schemas/base_schema'

module Roi::Schemas
  class NumberSchema < BaseSchema
    sig{ void }
    def initialize
      super

      @min = nil
      @max = nil

      add_class_test(Numeric, "must be Numeric")
      add_test("#{name}.min", :test_min)
      add_test("#{name}.max", :test_max)
    end

    sig{ params(min: Numeric).returns(NumberSchema) }
    def min(min)
      @min = min
      self
    end

    sig{ params(max: Numeric).returns(NumberSchema) }
    def max(max)
      @max = max
      self
    end

    private

    sig{ returns(String) }
    def name
      'int'
    end

    sig{
      params(value: Numeric, context: Roi::ValidationContext).
      returns(T.nilable(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail)))
    }
    def test_min(value, context)
      if @min && value < @min
        Fail(context.error("must be >= #{@min}"))
      end
    end

    sig{
      params(value: Numeric, context: Roi::ValidationContext).
      returns(T.nilable(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail)))
    }
    def test_max(value, context)
      if @max && value > @max
        Fail(context.error("must be <= #{@max}"))
      end
    end
  end
end
