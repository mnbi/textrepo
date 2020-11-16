require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryUpdateTest < Minitest::Test
  def setup
    @conf_rw = CONF_RW

    time_of_src = Time.new(2020, 1, 1, 1, 0, 0)
    stmp_src = Textrepo::Timestamp.new(time_of_src)
    repo_src = repo_path(CONF_RO)
    src = File.expand_path(timestamp_to_pathname(stmp_src) + '.md', repo_src)

    0.upto(1) { |i|
      time = Time.at(time_of_src.to_i + i)
      stmp = Textrepo::Timestamp.new(time)
      stmp_sfx = Textrepo::Timestamp.new(time, 88)
      repo = repo_path(@conf_rw)
      dst = File.expand_path(timestamp_to_pathname(stmp) + '.md', repo)
      dst_sfx = File.expand_path(timestamp_to_pathname(stmp_sfx) + '.md', repo)

      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.copy_file(src, dst)
      FileUtils.copy_file(src, dst_sfx)
    }
  end

  def test_it_can_update_the_content_of_text_in_the_repository
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    org_stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = ['content', 'was', 'updated']
    new_stamp = repo_rw.update(org_stamp, text)
    refute_equal org_stamp, new_stamp

    newpath = File.expand_path(timestamp_to_pathname(new_stamp) + '.md', repo_rw.path)
    content = nil
    File.open(newpath, 'r') { |f|
      content = f.readlines(chomp: true)
    }
    assert_equal text, content
  end

  def test_it_can_update_the_content_of_text_in_the_repository_with_suffix
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    suffix = 88
    org_stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), suffix)
    text = ['content', 'was', 'updated']
    new_stamp = repo_rw.update(org_stamp, text)
    refute_equal org_stamp, new_stamp

    newpath = File.expand_path(timestamp_to_pathname(new_stamp) + '.md', repo_rw.path)
    content = nil
    File.open(newpath, 'r') { |f|
      content = f.readlines(chomp: true)
    }
    assert_equal text, content
  end

  def test_it_fails_to_update_with_a_non_existing_timestamp
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    stamp = Textrepo::Timestamp.new(Time.new(1900, 1, 1, 1, 1, 1))
    text = ['content', 'was', 'updated']
    assert_raises(Textrepo::MissingTimestampError) {
      repo_rw.update(stamp, text)
    }
  end

  def test_it_fails_to_update_with_a_non_existing_timestamp_with_suffix
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    suffix = 89
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0), suffix)
    text = ['content', 'was', 'updated']
    assert_raises(Textrepo::MissingTimestampError) {
      repo_rw.update(stamp, text)
    }
  end

  def test_it_fails_to_update_with_empty_text
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = []
    assert_raises(Textrepo::EmptyTextError) {
      repo_rw.update(stamp, text)
    }
  end

  # [issue #28]
  def test_it_does_not_update_with_the_same_text
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    org_stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))

    text = repo_rw.read(org_stamp)
    new_stamp = repo_rw.update(org_stamp, text)

    assert_equal org_stamp, new_stamp
  end

  # [issue #40]
  def test_it_can_keep_timestamp_unchanged
    repo_rw = Textrepo::FileSystemRepository.new(@conf_rw)

    org_stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 1))
    text = ['content', 'was', 'updated']
    new_stamp = repo_rw.update(org_stamp, text, true)
    assert_equal org_stamp, new_stamp

    newpath = File.expand_path(timestamp_to_pathname(new_stamp) + '.md', repo_rw.path)
    content = nil
    File.open(newpath, 'r') { |f|
      content = f.readlines(chomp: true)
    }
    assert_equal text, content
  end
end
