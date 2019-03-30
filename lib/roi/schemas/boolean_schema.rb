require 'roi/schemas/base_schema'

module Roi::Schemas
  class BooleanSchema < BaseSchema
    def initialize
      super
      add_test('boolean') do |value, context|
        if ![true, false].include?(value)
          Fail(context.error('must be a Boolean'))
        end
      end
    end

    private

    def name
      'boolean'
    end
  end
end
