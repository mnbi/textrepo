module Textrepo
  ##
  # Timestamp is generated from a Time object.  It converts a time to
  # string in the obvious format, such "20201023122400".
  #
  # Since the obvious format contains only year, month, day, hour,
  # minute, and second, the resolution of time is a second.  That is,
  # two Time object those are different only in second will generates
  # equal Timestamp objects.
  #
  # If a client program of Textrepo::Timestamp wants to distinguish
  # those Time objects, an attribute `suffix` could be used.
  #
  # For example, the `suffix` will be converted into a 3 character
  # string, such "012", "345", "678", ... etc.  So, millisecond part
  # of a Time object will be suitable to pass as `suffix` when
  # creating a Timestamp object.

  class Timestamp
    include Comparable

    ##
    # Time object which generates the Timestamp object.

    attr_reader :time

    ##
    # An integer specified in `new` method to create the Timestamp object.

    attr_reader :suffix

    ##
    # Creates a Timestamp object from a Time object.  In addition, an
    # Integer can be passed as a suffix use.
    #
    # :call-seq:
    #   new(Time, Integer = nil) -> Timestamp

    def initialize(time, suffix = nil)
      @time = time
      @suffix = suffix
    end

    def <=>(other)              # :nodoc:
      result = (self.time <=> other.time)

      sfx = self.suffix || 0
      osfx = other.suffix || 0

      result == 0 ? (sfx <=> osfx) : result
    end

    ##
    # Generate an obvious time string.
    #
    #    %Y   %m %d %H %M %S  suffix
    #   "2020-12-30 12:34:56  (0 | nil)" -> "20201230123456"
    #   "2020-12-30 12:34:56  (7)"       -> "20201230123456_007"

    def to_s
      s = @time.strftime("%Y%m%d%H%M%S")
      s += "_#{"%03u" % @suffix}" unless @suffix.nil? || @suffix == 0
      s
    end

    class << self
      ##
      # Splits a string which represents a timestamp into components.
      # Each component represents a part of constructs to instantiate
      # a Time object.
      #
      #    yyyymoddhhmiss sfx      yyyy    mo    dd    hh    mi    ss    sfx
      #   "20201230123456"     -> "2020", "12", "30", "12", "34", "56"
      #   "20201230123456_789" -> "2020", "12", "30", "12", "34", "56", "789"
      #
      # Raises InvalidTimestampStringError if nil was passed as an arguemnt.

      def split_stamp(stamp_str)
        raise InvalidTimestampStringError, stamp_str if stamp_str.nil?
        #    yyyy  mo    dd    hh    mi      ss      sfx
        a = [0..3, 4..5, 6..7, 8..9, 10..11, 12..13, 15..17].map {|r| stamp_str[r]}
        a[-1].nil? ? a[0..-2] : a
      end

      ##
      # Generate a Timestamp object from a string which represents a
      # timestamp, such "20201028163400".
      #
      # Raises InvalidTimestampStringError if cannot convert the
      # argument into a Timestamp object.
      #
      # :call-seq:
      #     parse_s("20201028163400") -> Timestamp
      #     parse_s("20201028163529_034") -> Timestamp

      def parse_s(stamp_str)
        begin
          ye, mo, da, ho, mi, se, sfx = split_stamp(stamp_str).map(&:to_i)
          Timestamp.new(Time.new(ye, mo, da, ho, mi, se), sfx)
        rescue InvalidTimestampStringError, ArgumentError => e
          emsg = if stamp_str.nil?
            "(nil)"
          elsif stamp_str.empty?
            "(empty string)"
          else
            stamp_str
          end
          raise InvalidTimestampStringError, emsg
        end
      end

    end
  end
end
