module Rbnotes
  module Commands
    class Command
      def execute(args, conf)
        puts "executed."
      end
    end

    # Built-in commands:
    # - repo: prints the absolute path of the repository.
    # - conf: prints all of the current configuration settings.
    # - stamp: converts given TIME_STR into a timestamp.
    # - time: converts given STAMP into a time string.
    module Builtins
      class Help < Command
        def execute(_, _)
          puts "usage: rbnotes [command]"
        end
      end

      class Version < Command
        def execute(_, _)
          rbnotes_version = "rbnotes #{Rbnotes::VERSION} (#{Rbnotes::RELEASE})"
          textrepo_version = "textrepo #{Textrepo::VERSION}"
          puts "#{rbnotes_version} (#{textrepo_version})"
        end
      end

      class Repo < Command
        def execute(_, conf)
          name = conf[:repository_name]
          base = conf[:repository_base]
          type = conf[:repository_type]

          case type
          when :file_system
            "#{base}/#{name}"
          else
            "#{base}/#{name}"
          end
        end
      end

      class Conf < Command
        def execute(_, conf)
          conf.keys.sort.each { |k|
            puts "#{k}=#{conf[k]}"
          }
        end
      end

      class Stamp < Command
        def execute(args, _)
          puts "converts TIME_STR into a stamp"
        end
      end

      class Time < Command
        def execute(args, _)
          puts "converts STAMP into a time string"
        end
      end

    end

    class << self
      def load(cmd_name, plugins)
        cmd_name ||= "help"
        klass_name =  cmd_name.capitalize
        klass = nil

        begin
          klass = Builtins::const_get(klass_name, false)
        rescue NameError => _
          # try to load external class definition
          search_path = [ File.expand_path("commands", __dir__) ]
          search_path += plugins unless plugins.nil? || plugins.empty?

          while search_path.size > 0
            begin
              p = search_path.shift
              require File.expand_path(cmd_name, p)
            rescue LoadError => _
              next if search_path.size > 0
              raise Rbntoes::CommandNameError, cmd_name
            else
              klass = const_get(klass_name)
              break
            end
          end
        end
        klass.new
      end
    end

  end
end
