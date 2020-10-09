module Textrepo
  class Timestamp
    include Comparable

    def initialize(time)
      @time = time
    end

    def <=>(other)
      self.to_s <=> other.to_s
    end

    #  %Y   %m %d %H %M %S  %L
    # "2020-12-30 12:34:56 (0.789)" => "20201230123456_789"
    def to_s
      @time.strftime("%Y%m%d%H%M%S_%L")
    end

    #  %Y   %m %d %H %M %S  %L            %Y/%m/  %Y%m%d%H%M%S %L
    # "2020-12-30 12:34:56 (0.789)" => "2020/12/20201230123456_789"
    def to_pathname
      @time.strftime("%Y/%m/%Y%m%d%H%M%S_%L")
    end

    class << self
      #  yyyymoddhhmiss lll      yyyy    mo    dd    hh    mi    ss    lll
      # "20201230123456_789" => "2020", "12", "30", "12", "34", "56", "789"
      def split_stamp(stamp_str)
        #yyyy  mo    dd    hh    mi      ss      lll
        [0..3, 4..5, 6..7, 8..9, 10..11, 12..13, 15..17].map {|r| stamp_str[r]}
      end

      def parse_s(stamp_str)
        year, mon, day, hour, min, sec , msec = split_stamp(stamp_str).map(&:to_i)
        basetime = Time.new(year, mon, day, hour, min, sec)
        Timestamp.new(Time.at(basetime.to_i, msec, :millisecond))
      end

      # "2020/12/20201230123456" => "2020-12-30 12:34:56"
      def parse_pathname(pathname)
        parse_s(pathname[8..-1])
      end
    end
  end
end
