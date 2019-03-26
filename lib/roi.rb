require "roi/version"

module Roi
  def self.object
    Schemas::ObjectSchema.new
  end

  class Pass < Struct.new(:value)
    def ok?
      true
    end
  end

  class Fail
    def ok?
      false
    end
  end

  module Schemas
    class BaseSchema
      def validate(value)
        Pass.new(value)
      end
    end

    class ObjectSchema < BaseSchema
      def validate(value)
        if value.is_a?(Hash)
          Pass.new(value)
        else
          Fail.new
        end
      end
    end
  end
end
