require 'roi/schemas/base_schema'

module Roi::Schemas
  class NumberSchema < BaseSchema
    def initialize
      super

      add_test do |value, context|
        if value.is_a?(Numeric)
          Pass(value)
        else
          Fail([
            context.error(
              validator_name: name,
              message: 'must be a number',
            )
          ])
        end
      end

      add_test do |value, context|
        if @min && value < @min
          Fail([
            context.error(validator_name: "#{name}.min", message: "must be >= #{@min}")
          ])
        end
      end

      add_test do |value, context|
        if @max && value > @max
          Fail([
            context.error(validator_name: "#{name}.max", message: "must be <= #{@max}")
          ])
        end
      end
    end

    def name
      'int'
    end

    def min(min)
      @min = min
      self
    end

    def max(max)
      @max = max
      self
    end
  end
end
