require "test_helper"

class TextrepoTimestampTest < Minitest::Test
  def test_it_can_be_instantiated_with_time_instance
    time = Time.new(2020, 1, 1, 0, 0, 0)
    stamp = Textrepo::Timestamp.new(time)
    refute_nil stamp
  end

  def test_it_can_generate_string
    time = Time.new(2020, 1, 1, 0, 0, 1)
    stamp = Textrepo::Timestamp.new(time)
    assert_equal '20200101000001_000', stamp.to_s
  end

  def test_it_can_generate_pathname
    time = Time.new(2020, 1, 1, 0, 0, 2)
    stamp = Textrepo::Timestamp.new(time)
    assert_equal '2020/01/20200101000002_000', stamp.to_pathname
  end

  def test_it_is_comparable
    t0 = Time.new(2020, 1, 1, 0, 0, 3)
    t1 = Time.new(2020, 1, 1, 0, 0, 4)
    t2 = Time.new(2020, 1, 1, 0, 0, 4)
    assert t0 < t1
    assert t1 > t0
    assert t1 == t2
  end

  def test_it_can_be_generated_from_stamp_str
    time = Time.new(2020, 1, 1, 0, 0, 5)
    stamp0 = Textrepo::Timestamp.new(time)
    stamp1 = Textrepo::Timestamp.parse_s(stamp0.to_s)
    assert_equal stamp0, stamp1
  end

  def test_it_can_be_generated_from_pathname
    time = Time.new(2020, 1, 1, 0, 0, 6)
    stamp0 = Textrepo::Timestamp.new(time)
    stamp1 = Textrepo::Timestamp.parse_pathname(stamp0.to_pathname)
    assert_equal stamp0, stamp1
  end
end
