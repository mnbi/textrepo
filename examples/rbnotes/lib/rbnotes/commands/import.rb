module Rbnotes
  class Commands::Import < Commands::Command
    def execute(args, conf)
      file = args.shift
      unless file.nil?
        st = File::Stat.new(file)
        btime = st.respond_to?(:birthtime) ? st.birthtime : st.mtime
        stamp = Textrepo::Timestamp.new(btime)
        puts "Import [%s] (timestamp [%s]) ..." % [file, stamp]

        repo = Textrepo.init(conf)
        content = nil
        File.open(file, "r") {|f| content = f.readlines(chomp: true)}

        count = 0
        while count <= 999
          begin
            repo.create(stamp, content)
            break               # success to create a note
          rescue Textrepo::DuplicateTimestampError => e
            puts "A text with the timestamp (%s)" \
                 " has been already exists" \
                 " in the repository." % stamp

            repo_text = repo.read(stamp)
            if content == repo_text
              # if the content is the same to the target file,
              # the specified file has been already imported.
              # Then, there is nothing to do.  Just exit.
              puts "The text in the repository exactly matches" \
                   " the specified file.  It seems there is no need" \
                   " to import the file."
              exit              # normal end
            else
              puts "The text in the repository does not" \
                   " match the specified file.  Try to" \
                   " create a note again."
              count += 1
              time_with_ms = ::Time.at(btime.to_i, count * 1000)
              stamp = Textrepo::Timestamp.new(time_with_ms)
            end
          rescue Textrepo::EmptyTextError => e
            puts "... aborted."
            puts "The specified file is empyt."
            exit 1              # error
          end
        end
        if count > 999
          puts "Cannot create a text into the repository with the" \
               " specified file [%s].  Change the birthtime of the" \
               " target file, then retry." % file
        else
          puts "... Done."
        end
      else
        puts "not supecified FILE"
        super
      end
    end
  end
end
