# typed: true
require 'roi/schemas/base_schema'

module Roi::Schemas
  class AnySchema < BaseSchema
    sig{ void }
    def initialize
      super
      add_test('any', :test_any)
    end

    private

    sig{ returns(String) }
    def name
      'any'
    end

    sig{
      params(value: T.untyped, context: Roi::ValidationContext).
      returns(T.nilable(Roi::ValidationResults::Fail))
    }
    def test_any(value, context)
      if value.nil?
        Fail(context.error('must not be nil'))
      end
    end
  end
end
