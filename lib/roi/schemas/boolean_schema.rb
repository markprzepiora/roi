# typed: true
require 'roi/schemas/base_schema'
require 'sorbet-runtime'

module Roi::Schemas
  class BooleanSchema < BaseSchema
    extend T::Sig

    sig{ void }
    def initialize
      super
      add_test('boolean', :test_boolean)
    end

    private

    def name
      'boolean'
    end

    sig{
      params(value: T.untyped, context: Roi::ValidationContext).
      returns(T.nilable(T.any(Roi::ValidationResults::Pass, Roi::ValidationResults::Fail)))
    }
    def test_boolean(value, context)
      if ![true, false].include?(value)
        Fail(context.error('must be a Boolean'))
      end
    end
  end
end
