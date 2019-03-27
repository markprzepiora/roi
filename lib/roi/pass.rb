require 'roi'

class Roi::Pass < Struct.new(:value)
  def ok?
    true
  end
end
