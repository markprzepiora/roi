require 'roi/schemas/base_schema'

module Roi::Schemas
  class StringSchema < BaseSchema
    BLANK_RE = /\A[[:space:]]*\z/

    def initialize
      super
      add_test do |value, context|
        if !value.is_a?(String)
          Fail([
            context.error(
              validator_name: name,
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
            Fail([ context.error(validator_name: "#{name}.present", message: "must not be blank") ])
          end
        rescue Encoding::CompatibilityError
          Pass(value)
        end
      end
    end

    def regex(regex)
      add_test do |value, context|
        if !regex.match(value)
          Fail([ context.error(validator_name: "#{name}.regex", message: "must match #{regex.inspect}") ])
        end
      end
    end
  end
end
