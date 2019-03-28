require 'roi/validation_results'

class Roi::ValidationResults::Pass
  # The object successfully validated and returned by the schema.
  #
  # @return [Object]
  attr_reader :value

  def initialize(value)
    @value = value
  end

  # @return true
  def ok?
    true
  end
end
