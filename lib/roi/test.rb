require 'roi'

class Roi::Test
  extend Forwardable
  attr_reader :name, :proc, :fail_early, :pass_early

  def initialize(proc)
    @proc = proc
  end

  def_delegator :@proc, :call
end
