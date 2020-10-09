module Rbnotes
  class Commands::List < Commands::Command
    def execute(args, conf)
      num = args.shift
      if num.nil?
        require "io/console/size"
        row, _ = IO.console_size
        num = row - 1
      end

      repo = Textrepo.init(conf)
#      entries = repo.entries(num)
      puts "print a list of #{num} notes"
    end
  end
end
