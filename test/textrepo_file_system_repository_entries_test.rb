require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryEntriesTest < Minitest::Test
  def test_it_can_get_a_list_of_text_without_args
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    entries = repo.entries
    refute_nil entries
    assert_equal 8, entries.size
    assert entries.include?(Textrepo::Timestamp.parse_s("20200101010000"))
    assert entries.include?(Textrepo::Timestamp.parse_s("20200101010001"))
    assert entries.include?(Textrepo::Timestamp.parse_s("20200101010002"))
  end

  # [issue #25]
  def test_it_returns_array_of_timestamp_instances
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    entries = repo.entries
    entries.each { |e|
      assert_instance_of Textrepo::Timestamp, e
    }
  end

  def test_it_can_get_a_list_with_a_full_timestamp_str
    assert_entries_pattern("2020-01-01 01:00:00".delete("- :"), 2, CONF_RO)
  end

  def test_it_can_get_a_list_with_a_yyyymoddhhmiss_pattern
    assert_entries_pattern("2020-01-01 01:00:01".delete("- :"), 2, CONF_RO)
  end

  def test_it_can_get_a_list_with_a_yyyymodd_pattern
    assert_entries_pattern("2020-01-01".delete("-"), 8, CONF_RO)
  end

  def test_it_can_get_a_list_with_a_yyyy_pattern
    assert_entries_pattern("2020", 8, CONF_RO)
  end

  def test_it_can_get_a_list_with_a_modd_pattern
    assert_entries_pattern("0101", 8, CONF_RO)
  end

  # [issue #34]
  def test_it_can_get_a_list_with_a_yyyymo_pattern
    assert_entries_pattern("202001", 8, CONF_RO)
  end
end
