require "roi/version"

module Roi
  def self.string
    Schemas::StringSchema.new
  end

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
        Fail.new
      end

      private

      def Pass(value)
        Pass.new(value)
      end

      def Fail
        Fail.new
      end
    end

    class StringSchema < BaseSchema
      def validate(value)
        if value.is_a?(String)
          Pass(value)
        else
          Fail()
        end
      end
    end

    class ObjectSchema < BaseSchema
      def validate(value)
        if value.is_a?(Hash)
          Pass(value)
        else
          Fail()
        end
      end
    end
  end
end
