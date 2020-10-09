require "io/console/size"

module Rbnotes
  class Commands::List < Commands::Command
    def execute(args, conf)
      @row, @column = IO.console_size
      max = args.shift || @row - 1

      @repo = Textrepo.init(conf)
      @repo.notes[0, max].each { |timestamp_str|
        puts make_headline(timestamp_str)
      }
    end

    private
    # Makes a headline with the timestamp and subject of the notes, it
    # looks like as follows:
    #
    # |<------------------ console column size --------------------->|
    # +-- timestamp ---+  +--- subject (the 1st line of each note) --+
    # |                |  |                                          |
    # 20101010001000_123: # I love Macintosh.                        [EOL]
    # 20100909090909_999: # This is very very long long loooong subje[EOL]
    #                   ++
    #                    ^--- delimiter (2 characters)
    #
    # The subject part will truncate when it is long.
    def make_headline(timestamp_str)

      delimiter = ": "
      subject_part_width = @column - timestamp_str.size - delimiter.size - 1

      subject = @repo.read(Textrepo::Timestamp.parse_s(timestamp_str))[0]
      prefix = '# '
      subject = prefix + subject.lstrip if subject[0, 2] != prefix

      # TODO: This does not work correct when non-ascii characters are
      # in the subject, such as Japanese characters.  It must be fixed.
      timestamp_str + delimiter + subject[0, subject_part_width]
    end
  end
end
