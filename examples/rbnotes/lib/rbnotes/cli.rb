module Rbnotes
  module CLI
    def get_global_opts(args)
      {}
    end

    def get_cmd_name(args, opts)
      args.shift
    end
  end
end
