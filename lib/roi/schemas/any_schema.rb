require 'roi/schemas/base_schema'

module Roi::Schemas
  class AnySchema < BaseSchema
    def initialize
      super
      add_test('any') do |value, context|
        if value.nil?
          Fail(context.error('must not be nil'))
        end
      end
    end

    private

    def name
      'any'
    end
  end
end
