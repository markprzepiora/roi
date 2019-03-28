require 'roi/schemas/base_schema'

module Roi::Schemas
  class AnySchema < BaseSchema
    def initialize
      super
      add_test do |value, context|
        if value.nil?
          Fail([
            context.error(
              validator_name: name,
              message: 'must not be nil',
            )
          ])
        end
      end
    end

    private

    def name
      'any'
    end
  end
end
