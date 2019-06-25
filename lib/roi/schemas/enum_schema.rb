# typed: true
require 'roi/schemas/base_schema'
require 'set'

module Roi::Schemas
  class EnumSchema < BaseSchema
    sig{ void }
    def initialize
      super
      @valid_values = Set.new
      add_test('enum.values', :test_values)
    end

    sig{ params(valid_values: T.untyped).returns(Roi::Schemas::EnumSchema) }
    def values(*valid_values)
      @valid_values.merge(valid_values)
      self
    end

    private

    sig{ returns(String) }
    def name
      'enum'
    end

    sig{
      params(value: T.untyped, context: Roi::ValidationContext).
      returns(T.nilable(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail)))
    }
    def test_values(value, context)
      if !@valid_values.include?(value)
        Fail(context.error("must be one of #{@valid_values.inspect}"))
      end
    end
  end
end
