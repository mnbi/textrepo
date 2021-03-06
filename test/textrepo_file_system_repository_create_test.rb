require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryCreateTest < Minitest::Test
  def setup
    @conf_rw = CONF_RW
    setup_read_write_repo(@conf_rw)
  end

  def test_it_can_create_a_new_file_in_the_repository
    repo = Textrepo::FileSystemRepository.new(@conf_rw)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 2, 0, 0, 0))
    text = ['apple', 'orange', 'grape']
    repo.create(stamp, text)
    filepath = [repo.path, "2020/01/20200102000000.md"].join('/')
    assert FileTest.exist?(filepath)

    content = nil
    File.open(filepath, 'r') { |f|
      content = f.readlines(chomp: true)
    }

    assert_equal text, content
  end

  def test_it_can_create_a_new_file_in_the_repository_with_suffix
    repo = Textrepo::FileSystemRepository.new(@conf_rw)
    suffix = 9
    stamp = Textrepo::Timestamp.new(Time.new(2020, 2, 2, 0, 0, 0), suffix)
    text = ['apple', 'orange', 'grape']
    repo.create(stamp, text)
    filepath = [repo.path, "2020/02/20200202000000_009.md"].join('/')
    assert FileTest.exist?(filepath)

    content = nil
    File.open(filepath, 'r') { |f|
      content = f.readlines(chomp: true)
    }

    assert_equal text, content
  end

  def test_it_fails_to_create_with_a_existing_timestamp
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = ['overwrite']
    assert_raises(Textrepo::DuplicateTimestampError) {
      repo.create(stamp, text)
    }
  end

  def test_it_fails_to_create_with_a_existing_timestamp_with_suffix
    repo = Textrepo::FileSystemRepository.new(CONF_RO)
    suffix = 123
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), suffix)
    text = ['overwrite']
    assert_raises(Textrepo::DuplicateTimestampError) {
      repo.create(stamp, text)
    }
  end

  def test_it_fails_to_create_with_empty_text
    repo = Textrepo::FileSystemRepository.new(@conf_rw)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 2, 0, 0, 2))
    text = []
    assert_raises(Textrepo::EmptyTextError) {
      repo.create(stamp, text)
    }
  end

  def test_it_fails_to_create_with_empty_text_with_suffix
    repo = Textrepo::FileSystemRepository.new(@conf_rw)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 2, 2, 0, 0, 2))
    text = []
    assert_raises(Textrepo::EmptyTextError) {
      repo.create(stamp, text)
    }
  end
end
