require 'roi/schemas/base_schema'
require 'set'

module Roi::Schemas
  class EnumSchema < BaseSchema
    def initialize
      super
      @valid_values = Set.new
      add_test do |value, context|
        if !@valid_values.include?(value)
          Fail(context.error(
            validator_name: name,
            message: "must be one of #{@valid_values.inspect}",
          ))
        end
      end
    end

    def values(*valid_values)
      @valid_values.merge(valid_values)
      self
    end

    private

    def name
      'enum'
    end
  end
end
