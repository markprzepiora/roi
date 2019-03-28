require 'roi/schemas/base_schema'

module Roi::Schemas
  class StringSchema < BaseSchema
    BLANK_RE = /\A[[:space:]]*\z/
    ENCODED_BLANKS = Hash.new do |h, enc|
      h[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
    end

    def initialize
      super
      add_class_test(String)
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
            Fail(context.error(validator_name: "#{name}.present", message: "must not be blank"))
          end
        rescue Encoding::CompatibilityError
          if ENCODED_BLANKS[value.encoding].match?(value)
            Fail(context.error(validator_name: "#{name}.present", message: "must not be blank"))
          end
        end
      end
    end

    def regex(regex)
      add_test do |value, context|
        if !regex.match(value)
          Fail(context.error(validator_name: "#{name}.regex", message: "must match #{regex.inspect}"))
        end
      end
    end
  end
end
