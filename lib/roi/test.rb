# typed: true

require 'roi'

class Roi::Test
  extend Forwardable
  attr_reader :name, :method_name

  def initialize(name, method_name)
    @name = name
    @method_name = method_name
  end

  def run(schema, value, context)
    schema.send(method_name, value, context)
  end
end
