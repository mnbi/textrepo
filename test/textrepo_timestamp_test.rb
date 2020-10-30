require "test_helper"

class TextrepoTimestampTest < Minitest::Test
  def test_it_can_be_instantiated_with_time_instance
    time = Time.new(2020, 1, 1, 0, 0, 0)
    stamp = Textrepo::Timestamp.new(time)
    refute_nil stamp
  end

  def test_it_can_be_instantiated_with_time_and_suffix
    time = Time.new(2020, 2, 1, 0, 0, 0)
    suffix = 123
    stamp = Textrepo::Timestamp.new(time, suffix)
    refute_nil stamp
  end

  def test_it_has_an_attr_reader_for_time
    time = Time.new(2020, 1, 1, 0, 0, 0)
    stamp = Textrepo::Timestamp.new(time)
    refute_nil stamp
    assert_equal time, stamp.time
  end

  def test_it_has_an_attr_reader_for_suffix
    time = Time.new(2020, 2, 1, 0, 0, 0)
    suffix = 123
    stamp = Textrepo::Timestamp.new(time, suffix)
    refute_nil stamp
    assert_equal suffix, stamp.suffix
  end

  def test_it_can_generate_string
    time = Time.new(2020, 1, 1, 0, 0, 1)
    stamp = Textrepo::Timestamp.new(time)
    assert_equal '20200101000001', stamp.to_s
  end

  def test_it_can_generate_string_with_suffix
    time = Time.new(2020, 2, 1, 0, 0, 1)
    suffix = 234
    stamp = Textrepo::Timestamp.new(time, suffix)
    assert_equal '20200201000001_234', stamp.to_s
  end

  def test_it_can_generate_string_with_suffix_starts_0
    time = Time.new(2020, 2, 1, 0, 0, 1)
    suffix = 45
    stamp = Textrepo::Timestamp.new(time, suffix)
    assert_equal '20200201000001_045', stamp.to_s
  end

  def test_it_can_generate_string_with_suffix_starts_00
    time = Time.new(2020, 2, 1, 0, 0, 1)
    suffix = 6
    stamp = Textrepo::Timestamp.new(time, suffix)
    assert_equal '20200201000001_006', stamp.to_s
  end

  def test_it_is_comparable
    t0 = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 0, 0, 3))
    t1 = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 0, 0, 4))
    t2 = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 0, 0, 4))
    assert t0 < t1
    assert t1 > t0
    assert t1 == t2
  end

  def test_it_is_comparable_with_suffix
    t0 = Textrepo::Timestamp.new(Time.new(2020, 2, 1, 0, 0, 3), 456)
    t1 = Textrepo::Timestamp.new(Time.new(2020, 2, 1, 0, 0, 4), 456)
    t2 = Textrepo::Timestamp.new(Time.new(2020, 2, 1, 0, 0, 4), 456)
    t3 = Textrepo::Timestamp.new(Time.new(2020, 2, 1, 0, 0, 3))
    t4 = Textrepo::Timestamp.new(Time.new(2020, 2, 1, 0, 0, 3), 567)
    assert t0 < t1
    assert t1 > t0
    assert t1 == t2
    assert t0 > t3
    assert t0 < t4
    assert t2 > t4 
  end

  def test_split_stamp_fails_when_nil_was_passed
    assert_raises(Textrepo::InvalidTimestampStringError) {
      Textrepo::Timestamp.split_stamp(nil)
    }
  end

  def test_it_can_be_generated_from_stamp_str
    time = Time.new(2020, 1, 1, 0, 0, 5)
    stamp0 = Textrepo::Timestamp.new(time)
    stamp1 = Textrepo::Timestamp.parse_s(stamp0.to_s)
    assert_equal stamp0, stamp1
  end

  def test_it_can_be_generated_from_stamp_str_with_suffix
    time = Time.new(2020, 2, 1, 0, 0, 5)
    suffix = 789
    stamp0 = Textrepo::Timestamp.new(time, suffix)
    stamp1 = Textrepo::Timestamp.parse_s(stamp0.to_s)
    assert_equal stamp0, stamp1
  end

  def test_parse_s_fails_when_invalid_string_was_passed
    assert_raises(Textrepo::InvalidTimestampStringError) {
      Textrepo::Timestamp.parse_s("not_timestamp_string")
    }
  end
end
