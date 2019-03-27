require 'roi/schemas/base_schema'

module Roi::Schemas
  class BooleanSchema < BaseSchema
    def initialize
      super
      add_test do |value, context|
        if ![true, false].include?(value)
          Fail(context.error(
            validator_name: name,
            message: 'must be a Boolean',
          ))
        end
      end
    end

    def name
      'boolean'
    end
  end
end
