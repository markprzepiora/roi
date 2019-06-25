# typed: true
require 'roi/schemas/base_schema'

module Roi::Schemas
  class AnySchema < BaseSchema
    def initialize
      super
      add_test('any', :test_any)
    end

    private

    def name
      'any'
    end

    def test_any(value, context)
      if value.nil?
        Fail(context.error('must not be nil'))
      end
    end
  end
end
