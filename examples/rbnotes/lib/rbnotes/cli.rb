module Rbnotes
  class CLI
    class << self
      def instance
        @cli ||= new
      end
    end

    def load(name, parent)
      Commands::Command.new(name, parent)
    end

  end
end
