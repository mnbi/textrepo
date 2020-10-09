require 'fileutils'

module Textrepo
  # A concrete repository which uses the default file system as a storage.
  class FileSystemRepository < Repository
    attr_reader :path, :extname

    FAVORITE_REPOSITORY_NAME = 'notes'
    FAVORITE_EXTNAME = 'md'

    # `config` must be a Hash object.  It should hold the follwoing
    # values:
    #
    # - :repository_type (:file_system)
    # - :repository_name => basename of the root path for the repository
    # - :repository_base => the parent directory path for the repository
    # - :default_extname => extname for a file stored into in the repository
    #
    # The root path of the repository looks like the following:
    # - config[:repository_base]/config[:repository_name]
    # 
    # Default values are set when `repository_name` and `default_extname`
    # were not defined in `config`.
    def initialize(config)
      super
      base = config[:repository_base]
      @name ||= FAVORITE_REPOSITORY_NAME
      @path = File.expand_path("#{name}", base)
      FileUtils.mkdir_p(@path)
      @extname = config[:default_extname] || FAVORITE_EXTNAME
    end

    #
    # repository operations
    #

    # Creates a file into the repository, which contains the specified
    # text and is associated to the timestamp.
    def create(timestamp, text)
      abs = abspath(timestamp)
      raise DuplicateTimestampError, timestamp if FileTest.exist?(abs)
      raise EmptyTextError if text.nil? || text.empty?

      write_text(abs, text)
      timestamp
    end

    # Reads the file content in the repository.  Then, returns its
    # content.
    def read(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = nil
      File.open(abs, 'r') { |f|
        content = f.readlines(chomp: true)
      }
      content
    end

    # Updates the file content in the repository.  A new timestamp
    # will be attached to the text.
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

    # Deletes the file in the repository.
    def delete(timestamp)
      abs = abspath(timestamp)
      raise MissingTimestampError, timestamp unless FileTest.exist?(abs)
      content = read(timestamp)

      FileUtils.remove_file(abs)

      content
    end

    # Finds notes those timestamp matches the specified pattern.
    def notes(stamp_pattern = nil)
      results = []

      case stamp_pattern.to_s.size
      when "yyyymoddhhmiss_lll".size
        stamp = Timestamp.parse_s(stamp_pattern)
        if exist?(stamp)
          results << stamp.to_s
        end
      when 0, "yyyymoddhhmiss".size, "yyyymodd".size
        results += find_notes(stamp_pattern)
      when 4                    # "yyyy" or "modd"
        pat = nil
        # The following distinction is practically correct, but not
        # perfect.  It simply assumes that a year is greater than
        # 1231.  For, a year before 1232 is too old for us to create a
        # note (I believe...).
        if stamp_pattern.to_i > 1231
          # yyyy
          pat = stamp_pattern
        else
          # modd
          pat = "*#{stamp_pattern}"
        end
        results += find_notes(pat)
      end

      results
    end

    private
    def abspath(timestamp)
      filename = timestamp.to_pathname + ".#{@extname}"
      File.expand_path(filename, @path)
    end

    def write_text(abs, text)
      FileUtils.mkdir_p(File.dirname(abs))
      File.open(abs, 'w') { |f|
        text.each {|line| f.puts(line) }
      }
    end

    def timestamp_str(notepath)
      File.basename(notepath).delete_suffix(".#{@extname}")
    end

    def exist?(timestamp)
      FileTest.exist?(abspath(timestamp))
    end

    def find_notes(stamp_pattern)
      Dir.glob("#{@path}/**/#{stamp_pattern}*.#{@extname}").map { |e|
        timestamp_str(e)
      }
    end

  end
end
