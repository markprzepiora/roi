require 'roi/schemas/base_schema'

module Roi::Schemas
  class StringSchema < BaseSchema
    def initialize
      super
      add_test do |value, context|
        if value.is_a?(String)
          Pass(value)
        else
          Fail([
            context.error(
              validator_name: 'string',
              message: 'must be a string',
            )
          ])
        end
      end
    end

    def name
      'string'
    end
  end
end
