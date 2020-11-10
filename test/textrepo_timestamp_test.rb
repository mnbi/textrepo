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

  def test_it_ignores_subsec_of_time_object
    t0 = Time.new(2020, 11, 10, 16, 39, 0)
    t1 = Time.at(t0.to_i, 1)

    stamp = Textrepo::Timestamp.new(t1)
    assert_equal 0, stamp.time.subsec
  end

  def test_it_fails_if_given_suffix_is_out_of_range
    t0 = Time.new(2020, 11, 10, 21, 35, 0)
    assert_raises(Textrepo::ArgumentRangeError) {
      Textrepo::Timestamp.new(t0, 1000)
    }
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

  # [issue #31]
  def test_parse_s_fais_and_returns_friendly_error_message
    begin
      Textrepo::Timestamp.parse_s("") # empty string
    rescue Textrepo::InvalidTimestampStringError => e
      assert_includes e.message, "empty"
    end

    begin
      Textrepo::Timestamp.parse_s(nil)
    rescue Textrepo::InvalidTimestampStringError => e
      assert_includes e.message, "nil"
    end
  end

  # hash
  def test_it_has_same_hash_to_same_time_timestamp
    t0 = Time.new(2020, 11, 10, 16, 33, 0)
    ts1 = Textrepo::Timestamp.new(t0)
    ts2 = Textrepo::Timestamp.new(t0)

    refute ts1.object_id == ts2.object_id
    assert ts1.hash == ts2.hash
  end

  # eql?
  def test_it_equals_to_same_time_timestamp
    t0 = Time.new(2020, 11, 10, 16, 34, 1)
    ts1 = Textrepo::Timestamp.new(t0)
    ts2 = Textrepo::Timestamp.new(t0)

    refute ts1.object_id == ts2.object_id
    assert ts1.eql?(ts2)
  end

  # +
  def test_it_accepts_plus_operation
    t0 = Time.new(2020, 11, 10, 16, 35, 2)
    t1 = t0 + 100
    ts0 = Textrepo::Timestamp.new(t0)
    ts1 = ts0 + 100
    assert_equal t1.sec, ts1.time.sec
    assert_equal t1.min, ts1.time.min
  end

  def test_plus_op_generates_a_new_timestamp_object_with_nil_as_suffix
    t0 = Time.new(2020, 11, 10, 16, 35, 3)
    t1 = t0 + 100
    ts0 = Textrepo::Timestamp.new(t0, 45)
    ts1 = ts0 + 100
    assert ts1.suffix.nil?
    assert_equal t1.sec, ts1.time.sec
    assert_equal t1.min, ts1.time.min
  end

  # -
  def test_it_accepts_minus_operation_with_time
    t0 = Time.new(2020, 11, 10, 16, 36, 4)
    t1 = Time.new(2020, 11, 10, 16, 37, 5)
    ts1 = Textrepo::Timestamp.new(t1)

    assert_equal t1 - t0, ts1 - t0
  end

  def test_it_accepts_minus_operation_with_timestamp
    t0 = Time.new(2020, 11, 10, 16, 36, 5)
    t1 = Time.new(2020, 11, 10, 16, 37, 7)
    ts0 = Textrepo::Timestamp.new(t0)
    ts1 = Textrepo::Timestamp.new(t1)

    assert_equal t1 - t0, ts1 - ts0
  end

  def test_it_accepts_minus_operation_with_integer
    t0 = Time.new(2020, 11, 10, 16, 36, 8)
    t1 = t0 - 3670
    ts0 = Textrepo::Timestamp.new(t0)
    ts1 = ts0 - 3670
    assert_equal t1.sec, ts1.time.sec
    assert_equal t1.min, ts1.time.min
  end

  def test_minus_op_generates_a_new_timestamp_object_with_nil_as_suffix
    t0 = Time.new(2020, 11, 10, 16, 36, 9)
    t1 = t0 - 3670
    ts0 = Textrepo::Timestamp.new(t0, 76)
    ts1 = ts0 - 3670
    assert ts1.suffix.nil?
    assert_equal t1.sec, ts1.time.sec
    assert_equal t1.min, ts1.time.min
  end

  def test_it_raises_type_error_when_nil_was_passed_to_minus_op
    t0 = Time.new(2020, 11, 10, 16, 36, 10)
    ts0 = Textrepo::Timestamp.new(t0)
    assert_raises(TypeError) { ts0 - nil }
  end

  def test_it_raises_argument_error_when_invalid_arg_was_passed_to_minus_op
    t0 = Time.new(2020, 11, 10, 16, 36, 10)
    ts0 = Textrepo::Timestamp.new(t0)
    assert_raises(ArgumentError) { ts0 - {} }
  end

  # to_a
  def test_it_generates_array_of_timestamp_components
    time_components = [2020, 11, 10, 16, 37, 0]
    t0 = Time.new(*time_components)
    ts0 = Textrepo::Timestamp.new(t0)
    assert_equal time_components, ts0.to_a

    suffix = 65
    ts1 = Textrepo::Timestamp.new(t0, suffix)
    assert_equal [*time_components, suffix], ts1.to_a
  end

  # []
  def test_slice_accepts_a_integer
    t0 = Time.new(2020, 11, 10, 16, 38, 0)
    ts0 = Textrepo::Timestamp.new(t0)
    "20201110163800".split(//).each_with_index { |c, i|
      assert_equal c, ts0[i]
    }
  end

  def test_slice_accepts_a_pair_of_integers
    t0 = Time.new(2020, 11, 10, 16, 38, 1)
    ts0 = Textrepo::Timestamp.new(t0)
    assert_equal "2020", ts0[0, 4]
    assert_equal "11", ts0[4, 2]
    assert_equal "10", ts0[6, 2]
    assert_equal "16", ts0[8, 2]
    assert_equal "38", ts0[10, 2]
    assert_equal "01", ts0[12, 2]
  end

  def test_slice_accpets_a_range
    t0 = Time.new(2020, 11, 10, 16, 38, 2)
    ts0 = Textrepo::Timestamp.new(t0)
    assert_equal "2020", ts0[0..3]
    assert_equal "2011", ts0[2...6]
    assert_equal "20201110163802", ts0[0..20]
  end

  def test_slice_accepts_some_symbols
    t0 = Time.new(2020, 11, 10, 16, 38, 3)
    ts0 = Textrepo::Timestamp.new(t0, 43)
    assert_equal "2020", ts0[:year]
    assert_equal "11", ts0[:mon]
    assert_equal "11", ts0[:month]
    assert_equal "10", ts0[:day]
    assert_equal "16", ts0[:hour]
    assert_equal "38", ts0[:min]
    assert_equal "03", ts0[:sec]
    assert_equal "043", ts0[:suffix]

    ts1 = Textrepo::Timestamp.new(t0)
    assert ts1[:suffix].nil?
  end

  # next
  def test_next_returns_timestamp_object_holds_time_next
    t0 = Time.new(2020, 11, 16, 21, 17, 0)
    ts0 = Textrepo::Timestamp.new(t0)
    ts1 = ts0.next
    refute ts0.object_id == ts1.object_id
    refute ts0.eql?(ts1)
    refute ts0 == ts1
    assert_equal ts0.time.to_i + 1, ts1.time.to_i
  end

  def test_succ_returns_timestamp_object_holds_time_succ
    t0 = Time.new(2020, 11, 16, 21, 17, 1)
    ts0 = Textrepo::Timestamp.new(t0)
    ts1 = ts0.succ
    refute ts0.object_id == ts1.object_id
    refute ts0.eql?(ts1)
    refute ts0 == ts1
    assert_equal ts0.time.to_i + 1, ts1.time.to_i
  end

  def test_next_returns_timestamp_object_suffix_incremented
    t0 = Time.new(2020, 11, 16, 21, 17, 2)
    ts0 = Textrepo::Timestamp.new(t0, 32)
    ts1 = ts0.next(true)
    refute ts0.object_id == ts1.object_id
    refute ts0.eql?(ts1)
    refute ts0 == ts1
    assert_equal ts0.suffix + 1, ts1.suffix
  end

  def test_next_returns_timestamp_object_suffix
    t0 = Time.new(2020, 11, 16, 21, 17, 3)
    ts0 = Textrepo::Timestamp.new(t0)
    ts1 = ts0.next(true)
    refute ts0.object_id == ts1.object_id
    refute ts0.eql?(ts1)
    refute ts0 == ts1
    assert ts0.suffix.nil?
    assert_equal 1, ts1.suffix
  end

  def test_next_fails_if_next_suffix_is_out_of_range
    t0 = Time.new(2020, 11, 16, 21, 17, 4)
    ts0 = Textrepo::Timestamp.new(t0, 999)
    assert_raises(Textrepo::ArgumentRangeError) {
      ts0.next(true)
    }
  end

  # next!
  def test_destructive_next_increase_itself
    t0 = Time.new(2020, 11, 16, 21, 17, 5)
    ts0 = Textrepo::Timestamp.new(t0)
    ts0.next!
    assert_equal t0.to_i + 1, ts0.time.to_i
  end

  def test_destructive_next_increse_suffix_if_use_suffix
    t0 = Time.new(2020, 11, 16, 21, 17, 6)
    suffix = 21
    ts0 = Textrepo::Timestamp.new(t0, suffix)
    ts0.next!(true)
    assert_equal suffix + 1, ts0.suffix
  end

  def test_destructive_next_set_suffix_if_use_suffix
    t0 = Time.new(2020, 11, 16, 21, 17, 7)
    ts0 = Textrepo::Timestamp.new(t0)
    ts0.next!(true)
    assert_equal 1, ts0.suffix
  end

  def test_destructive_next_fails_if_next_suffix_is_out_of_range
    t0 = Time.new(2020, 11, 16, 21, 17, 8)
    ts0 = Textrepo::Timestamp.new(t0, 999)
    assert_raises(Textrepo::ArgumentRangeError) {
      ts0.next!(true)
    }
  end

  # split
  def test_split_returns_array_of_timestamp_parts
    parts = [2020, 11, 16, 22, 14, 0]
    t0 = Time.new(*parts)
    ts0 = Textrepo::Timestamp.new(t0)
    assert_equal parts, ts0.split.map{ |p| p.to_i }
  end

  def test_split_returns_array_of_timestamp_parts_with_suffix
    parts = [2020, 11, 16, 22, 14, 1]
    suffix = 21
    t0 = Time.new(*parts)
    ts0 = Textrepo::Timestamp.new(t0, suffix)
    assert_equal parts << suffix, ts0.split.map{ |p| p.to_i }
  end

  def test_split_with_block_works
    parts = [2020, 11, 16, 22, 14, 1]
    t0 = Time.new(*parts)
    ts0 = Textrepo::Timestamp.new(t0)
    result = []
    ts0.split { |p| result << p.to_i }
    assert_equal parts, result
  end

end
