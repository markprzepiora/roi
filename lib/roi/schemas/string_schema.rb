require 'roi/schemas/base_schema'
require 'roi/support'
require 'uri'

using Roi::Support

module Roi::Schemas
  class StringSchema < BaseSchema
    # @!visibility private
    BLANK_RE = /\A[[:space:]]*\z/

    # @!visibility private
    ENCODED_BLANKS = Hash.new do |h, enc|
      h[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
    end

    # Lifted from `URI::MailTo::EMAIL_REGEXP` in Ruby 2.2+
    #
    # @!visibility private
    EMAIL_REGEX = /
      \A
      [a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+
      @
      [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?
      (?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*
      \z
    /x

    # @!visibility private
    def initialize
      super
      add_class_test(String)

      add_test('string.min_length') do |value, context|
        if @min_length && value.length < @min_length
          Fail(context.error(
            validator_name: "#{name}.min_length",
            message: "length must be ≥ #{@min_length}"
          ))
        end
      end

      add_test('string.max_length') do |value, context|
        if @max_length && value.length > @max_length
          Fail(context.error(
            validator_name: "#{name}.max_length",
            message: "length must be ≤ #{@max_length}"
          ))
        end
      end
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
      add_test('string.present') do |value, context|
        begin
          if value.empty? || BLANK_RE.match?(value)
            Fail(context.error("must not be blank"))
          end
        rescue Encoding::CompatibilityError
          if ENCODED_BLANKS[value.encoding].match?(value)
            Fail(context.error("must not be blank"))
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
    def regex(regex, validator_name = nil, error_message = nil)
      error_message ||= "must match #{regex.inspect}"
      validator_name ||= "string.regex"

      add_test(validator_name) do |value, context|
        if !regex.match(value)
          Fail(context.error(error_message))
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
      regex(/\A\d+\z/, 'string.digits', 'must contain only digits 0-9')
    end

    # String must be a certain length.
    #
    # May be an exact length, or a range.
    #
    # @param int_or_range [Integer, Range<Integer>]
    def length(int_or_range)
      case int_or_range
      when Integer
        min_length(int_or_range)
        max_length(int_or_range)
      when Range
        min_length(int_or_range.min)
        max_length(int_or_range.max)
      else
        fail ArgumentError, "Argument must be an Integer or a Range"
      end
      self
    end

    def min_length(min_length)
      if !min_length.is_a?(Integer)
        fail ArgumentError, "Argument must be an Integer"
      end

      @min_length = min_length
      self
    end

    def max_length(max_length)
      if !max_length.is_a?(Integer)
        fail ArgumentError, "Argument must be an Integer"
      end

      @max_length = max_length
      self
    end

    def email
      regex(EMAIL_REGEX, 'string.email', 'must be an email address')
    end

    private

    def name
      'string'
    end
  end
end
