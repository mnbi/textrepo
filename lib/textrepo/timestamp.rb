module Textrepo
  ##
  # Timstamp is generated from a Time object.  It converts a time to
  # string in the obvious format, such "20201023122400".
  #
  class Timestamp
    include Comparable

    attr_reader :time, :suffix

    ##
    # :call-seq:
    #   new(Time, Integer = nil)
    #
    def initialize(time, suffix = nil)
      @time = time
      @suffix = suffix
    end

    def <=>(other)
      result = (self.time <=> other.time)

      sfx = self.suffix || 0
      osfx = other.suffix || 0

      result == 0 ? (sfx <=> osfx) : result
    end

    ##
    # Generate an obvious time string.
    #
    # ```
    #  %Y   %m %d %H %M %S  suffix
    # "2020-12-30 12:34:56  (0 | nil)" => "20201230123456"
    # "2020-12-30 12:34:56  (7)"       => "20201230123456_007"
    # ```
    #
    def to_s
      s = @time.strftime("%Y%m%d%H%M%S")
      s += "_#{"%03u" % @suffix}" unless @suffix.nil? || @suffix == 0
      s
    end

    class << self
      ##
      # ```
      #  yyyymoddhhmiss sfx      yyyy    mo    dd    hh    mi    ss    sfx
      # "20201230123456"     => "2020", "12", "30", "12", "34", "56"
      # "20201230123456_789" => "2020", "12", "30", "12", "34", "56", "789"
      # ```
      #
      def split_stamp(stamp_str)
        #    yyyy  mo    dd    hh    mi      ss      sfx
        a = [0..3, 4..5, 6..7, 8..9, 10..11, 12..13, 15..17].map {|r| stamp_str[r]}
        a[-1].nil? ? a[0..-2] : a
      end

      def parse_s(stamp_str)
        year, mon, day, hour, min, sec , sfx = split_stamp(stamp_str).map(&:to_i)
        Timestamp.new(Time.new(year, mon, day, hour, min, sec), sfx)
      end

    end
  end
end
