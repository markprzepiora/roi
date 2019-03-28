require 'roi/schemas/base_schema'

module Roi::Schemas
  class StringSchema < BaseSchema
    # @!visibility private
    BLANK_RE = /\A[[:space:]]*\z/

    # @!visibility private
    ENCODED_BLANKS = Hash.new do |h, enc|
      h[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
    end

    # @!visibility private
    def initialize
      super
      add_class_test(String)
    end

    # Reject empty strings.
    #
    # @example
    #   Roi.string.nonempty.validate('   ').ok? # => true
    #   Roi.string.nonempty.validate('').ok? # => false
    #
    # @return self
    def nonempty
      invalid('')
    end

    # Reject blank strings.
    #
    # @example
    #   Roi.string.present.validate("  hello there ").ok? # => true
    #   Roi.string.present.validate("  \n  \t").ok? # => false
    #
    # @return self
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

    # String must match the specified regex.
    #
    # @example
    #   Roi.string.regex(/\A\d+\z/).validate("123").ok? # => true
    #   Roi.string.regex(/\A\d+\z/).validate("123-bar").ok? # => false
    #
    # @return self
    def regex(regex)
      add_test do |value, context|
        if !regex.match(value)
          Fail(context.error(validator_name: "#{name}.regex", message: "must match #{regex.inspect}"))
        end
      end
    end

    # String must be composed entirely of digits. Useful for specifying numeric IDs.
    #
    # @example
    #   Roi.string.digits.validate("123").ok? # => true
    #   Roi.string.digits.validate("-1").ok? # => false
    #   Roi.string.digits.validate("123-foo").ok? # => false
    def digits
      regex(/\A\d+\z/)
    end

    private

    def name
      'string'
    end
  end
end
