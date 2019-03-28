require 'roi/validation_results'

class Roi::ValidationResults::Pass < Struct.new(:value)
  def ok?
    true
  end
end
