require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryReadTest < Minitest::Test
  def test_it_can_read_the_content_of_text_in_the_repository
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = repo.read(stamp)
    refute_empty text
  end

  def test_it_can_read_the_content_of_text_in_the_repository_with_suffix
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    suffix = 123
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), suffix)
    text = repo.read(stamp)
    refute_empty text
  end

  def test_it_fails_to_read_with_a_non_existing_timestamp
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    stamp = Textrepo::Timestamp.new(Time.new(1900, 12, 31, 12, 34, 56))
    assert_raises(Textrepo::MissingTimestampError) {
      repo.read(stamp)
    }
  end

  def test_it_fails_to_read_with_a_non_existing_timestamp_with_suffix
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    stamp = Textrepo::Timestamp.new(Time.new(1900, 12, 31, 12, 34, 56), 999)
    assert_raises(Textrepo::MissingTimestampError) {
      repo.read(stamp)
    }
  end
end
