# typed: true
require 'roi/schemas/base_schema'

module Roi::Schemas
  class BooleanSchema < BaseSchema
    def initialize
      super
      add_test('boolean', :test_boolean)
    end

    private

    def name
      'boolean'
    end

    def test_boolean(value, context)
      if ![true, false].include?(value)
        Fail(context.error('must be a Boolean'))
      end
    end
  end
end
