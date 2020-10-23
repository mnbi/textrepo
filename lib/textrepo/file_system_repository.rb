require 'fileutils'

module Textrepo
  ##
  # A concrete class which implements Repository interfaces.  This
  # repository uses the default file system of the operating system as
  # a text storage.
  class FileSystemRepository < Repository
    ##
    # Repository root.
    attr_reader :path

    ##
    # Extension of notes sotres in the repository.
    attr_reader :extname

    ##
    # Default name for the repository which uses when no name is
    # specified in the configuration settings.
    FAVORITE_REPOSITORY_NAME = 'notes'

    ##
    # Default extension of notes which uses when no extname is
    # specified in the configuration settings.
    FAVORITE_EXTNAME = 'md'

    ##
    # Creates a new repository object.  The argument, `conf` must be a
    # Hash object.  It should hold the follwoing values:
    #
    # - MANDATORY:
    #   - :repository_type => `:file_system`
    #   - :repository_base => the parent directory path for the repository
    # - OPTIONAL: (if not specified, default values are used)
    #   - :repository_name => basename of the root path for the repository
    #   - :default_extname => extname for a file stored into in the repository
    #
    # The root path of the repository looks like the following:
    # - conf[:repository_base]/conf[:repository_name]
    # 
    # Default values are set when `repository_name` and `default_extname`
    # were not defined in `conf`.
    #
    def initialize(conf)
      super
      base = conf[:repository_base]
      @name ||= FAVORITE_REPOSITORY_NAME
      @path = File.expand_path("#{name}", base)
      FileUtils.mkdir_p(@path)
      @extname = conf[:default_extname] || FAVORITE_EXTNAME
    end

    ##
    # Creates a file into the repository, which contains the specified
    # text and is associated to the timestamp.
    #
    # :call-seq:
    #     create(Timestamp, Array) => Timestamp
    #
    def create(timestamp, text)
      abs = abspath(timestamp)
      raise DuplicateTimestampError, timestamp if FileTest.exist?(abs)
      raise EmptyTextError if text.nil? || text.empty?

      write_text(abs, text)
      timestamp
    end

    ##
    # Reads the file content in the repository.  Then, returns its
    # content.
    #
    # :call-seq:
    #     read(Timestamp) => Array
    #
    def read(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = nil
      File.open(abs, 'r') { |f|
        content = f.readlines(chomp: true)
      }
      content
    end

    ##
    # Updates the file content in the repository.  A new timestamp
    # will be attached to the text.
    #
    # :call-seq:
    #     update(Timestamp, Array) => Timestamp
    #
    def update(timestamp, text)
      raise EmptyTextError if text.empty?
      org_abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(org_abs)

      # the text must be stored with the new timestamp
      new_stamp = Timestamp.new(Time.now)
      new_abs = abspath(new_stamp)
      write_text(new_abs, text)

      # delete the original file in the repository
      FileUtils.remove_file(org_abs)

      new_stamp
    end

    ##
    # Deletes the file in the repository.
    #
    # :call-seq:
    #     delete(Timestamp) => Array
    #
    def delete(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = read(timestamp)

      FileUtils.remove_file(abs)

      content
    end

    ##
    # Finds entries of text those timestamp matches the specified pattern.
    #
    # :call-seq:
    #     entries(String = nil) => Array
    #
    def entries(stamp_pattern = nil)
      results = []

      case stamp_pattern.to_s.size
      when "yyyymoddhhmiss_lll".size
        stamp = Timestamp.parse_s(stamp_pattern)
        if exist?(stamp)
          results << stamp.to_s
        end
      when 0, "yyyymoddhhmiss".size, "yyyymodd".size
        results += find_entries(stamp_pattern)
      when 4                    # "yyyy" or "modd"
        pat = nil
        # The following distinction is practically correct, but not
        # perfect.  It simply assumes that a year is greater than
        # 1231.  For, a year before 1232 is too old for us to create
        # any text (I believe...).
        if stamp_pattern.to_i > 1231
          # yyyy
          pat = stamp_pattern
        else
          # modd
          pat = "*#{stamp_pattern}"
        end
        results += find_entries(pat)
      end

      results
    end

    # :stopdoc:
    private
    def abspath(timestamp)
      filename = timestamp_to_pathname(timestamp) + ".#{@extname}"
      File.expand_path(filename, @path)
    end

    ##
    # ```
    #  %Y   %m %d %H %M %S  suffix        %Y/%m/  %Y%m%d%H%M%S %L
    # "2020-12-30 12:34:56  (0 | nil)" => "2020/12/20201230123456"
    # "2020-12-30 12:34:56  (7)"       => "2020/12/20201230123456_007"
    # ```
    def timestamp_to_pathname(timestamp)
      yyyy, mo = Timestamp.split_stamp(timestamp.to_s)[0..1]
      File.join(yyyy, mo, timestamp.to_s)
    end

    def write_text(abs, text)
      FileUtils.mkdir_p(File.dirname(abs))
      File.open(abs, 'w') { |f|
        text.each {|line| f.puts(line) }
      }
    end

    def timestamp_str(text_path)
      File.basename(text_path).delete_suffix(".#{@extname}")
    end

    def exist?(timestamp)
      FileTest.exist?(abspath(timestamp))
    end

    def find_entries(stamp_pattern)
      Dir.glob("#{@path}/**/#{stamp_pattern}*.#{@extname}").map { |e|
        timestamp_str(e)
      }
    end

  end
end
