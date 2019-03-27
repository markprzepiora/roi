require 'set'
require 'roi/schemas'
require 'roi/validation_context'
require 'roi/pass'
require 'roi/fail'

module Roi::Schemas
  class BaseSchema
    def initialize
      @tests = []
      @required = false
      @valids = Set.new
    end

    def name
      'base'
    end

    def validate(value, context = nil)
      context ||= Roi::ValidationContext.new(path: [], parent: nil)

      # Matches of 'valids' values override failing tests, since the intention
      # is to allow restrictions to be overruled with a whitelist.
      if @valids.include?(value)
        return Pass(value)
      end

      @tests.each do |test|
        result = test.call(value, context) || Pass(value)
        return result if !result.ok?
        value = result.value
      end

      Pass(value)
    end

    # A schema being "required" or "optional" changes its behaviour when it
    # applies to an object's value. By default, defined key/values can be
    # missing from the validated object.
    #
    # For example:
    #
    #     schema = Roi.object({
    #       name: Roi.string,
    #     })
    #     schema.validate({}).ok?
    #     # => true
    #
    # However, this isn't always what we want. If a key must be present in
    # the validated object, then it can be marked as required.
    #
    #     schema = Roi.object({
    #       name: Roi.string.required,
    #     })
    #     schema.validate({}).ok?
    #     # => false
    def required
      @required = true
      self
    end

    def required?
      !!@required
    end

    def allow(*valids)
      valids.each do |value|
        @valids.add(value)
      end
      self
    end

    def or_nil
      allow(nil)
    end

    private

    def add_test(&block)
      @tests << block
    end

    def Pass(value)
      Roi::Pass.new(value)
    end

    def Fail(errors = [])
      Roi::Fail.new(errors)
    end
  end
end
