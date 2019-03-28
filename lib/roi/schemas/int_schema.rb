require 'roi/schemas/base_schema'

module Roi::Schemas
  class IntSchema < BaseSchema
    def initialize
      super

      add_test do |value, context|
        respond_to_to_i = value.respond_to?(:to_i)
        value_to_i = respond_to_to_i && value.to_i

        if respond_to_to_i && value_to_i == value && value_to_i.is_a?(Integer)
          Pass(value_to_i)
        else
          Fail(context.error(validator_name: name, message: 'must be an Integer'))
        end
      end

      add_test do |value, context|
        if @min && value < @min
          Fail(context.error(validator_name: "#{name}.min", message: "must be >= #{@min}"))
        end
      end

      add_test do |value, context|
        if @max && value > @max
          Fail(context.error(validator_name: "#{name}.max", message: "must be <= #{@max}"))
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

    def cast_value(value, context)
      Pass(Integer(value))
    rescue ArgumentError => e
      Fail(context.error(validator_name: "#{name}.cast", message: "cannot be cast to an Integer"))
    end

    def name
      'int'
    end
  end
end
