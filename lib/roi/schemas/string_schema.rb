require 'roi/schemas/base_schema'

module Roi::Schemas
  class StringSchema < BaseSchema
    BLANK_RE = /\A[[:space:]]*\z/

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

    def nonempty
      invalid('')
    end

    def present
      add_test do |value, context|
        begin
          if value.empty? || BLANK_RE.match?(value)
            Fail([
              context.error(validator_name: "string.present", message: "must not be blank")
            ])
          end
        rescue Encoding::CompatibilityError
          Pass(value)
        end
      end
      self
    end
  end
end
