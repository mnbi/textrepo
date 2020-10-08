module Rbnotes
  class CommandNameError < Error
    def initialize(name)
      super "not found such command: %s" % name
    end
  end
end
