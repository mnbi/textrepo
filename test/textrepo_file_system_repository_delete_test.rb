require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryDeleteTest < Minitest::Test
  def setup
    @conf_rw = CONF_RW
    setup_read_write_repo(@conf_rw)
  end

  def test_it_can_delete_text_in_the_repository
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    path = File.expand_path(timestamp_to_pathname(stamp) + '.md', repo_rw.path)

    expected = []
    File.open(path, 'r') { |f| expected = f.readlines(chomp: true) }

    content = repo_rw.delete(stamp)
    refute_empty content
    assert_equal expected, content
    refute FileTest.exist?(path)
  end

  def test_it_can_delete_text_in_the_repository_with_suffix
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    suffix = 88
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), suffix)
    path = File.expand_path(timestamp_to_pathname(stamp) + '.md', repo_rw.path)

    expected = []
    File.open(path, 'r') { |f| expected = f.readlines(chomp: true) }

    content = repo_rw.delete(stamp)
    refute_empty content
    assert_equal expected, content
    refute FileTest.exist?(path)
  end

  def test_it_fails_to_delete_with_a_non_existing_timestamp
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    stamp = Textrepo::Timestamp.new(Time.new(1900, 1, 1, 1, 1, 1))
    assert_raises(Textrepo::MissingTimestampError) {
      repo_rw.delete(stamp)
    }
  end

  def test_it_fails_to_delete_with_a_non_existing_timestamp_with_suffix
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    suffix = 89
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), suffix)
    assert_raises(Textrepo::MissingTimestampError) {
      repo_rw.delete(stamp)
    }
  end
end
