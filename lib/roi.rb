require "roi/version"

module Roi
  def self.object
    Schema.new
  end

  class OK < Struct.new(:value)
    def ok?
      true
    end
  end

  class Schema
    def validate(value)
      OK.new(value)
    end
  end
end
