require 'fileutils'
require 'test_helper'

class TextrepoFileSystemRepositoryTest < Minitest::Test
  def setup
    @config_ro = {
      :repository_type => :file_system,
      :repository_name => "test_repo",
      :repository_base => File.expand_path("fixtures", __dir__)
    }

    @config_rw = {
      :repository_type => :file_system,
      :repository_name => "test_repo",
      :repository_base => File.expand_path("sandbox", __dir__),
      :default_extname => 'md'
    }

    # prepare a file into the sandobx repository
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))

    repo_rw_path = File.expand_path(@config_rw[:repository_name],
                                    @config_rw[:repository_base])
    dst = File.expand_path(stamp.to_pathname + '.md', repo_rw_path)

    repo_ro_path = File.expand_path(@config_ro[:repository_name],
                                    @config_ro[:repository_base])
    src = File.expand_path(stamp.to_pathname + '.md', repo_ro_path)

    FileUtils.mkdir_p(File.dirname(dst))
    FileUtils.copy_file(src, dst)
  end

  def test_it_can_be_instantiated_with_valid_config
    repo = Textrepo::FileSystemRepository.new(@config_ro)
    assert repo
  end

  # for accessor
  def test_it_has_appropriate_type
    expected = :file_system
    repo = Textrepo::FileSystemRepository.new(@config_ro)
    assert_equal expected, repo.type
  end

  def test_it_has_default_name_value
    expected = 'notes'
    config = @config_rw.clone
    config.delete(:repository_name)
    repo = Textrepo::FileSystemRepository.new(config)
    assert_equal expected, repo.name
  end

  def test_it_has_accessor_for_path_attribute
    repo = Textrepo::FileSystemRepository.new(@config_ro)
    expected = File.expand_path(@config_ro[:repository_name], @config_ro[:repository_base])
    assert_equal expected, repo.path
  end

  def test_it_has_accessor_for_extname_attribute
    expected = "txt"
    config = @config_ro.clone
    config[:default_extname] = expected
    repo = Textrepo::FileSystemRepository.new(config)
    assert_equal expected, repo.extname
  end

  # for `create(timestamp, text)`
  def test_it_can_create_a_new_file_in_the_repository
    repo = Textrepo::FileSystemRepository.new(@config_rw)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 2, 0, 0, 0))
    text = ['apple', 'orange', 'grape']
    repo.create(stamp, text)
    filepath = [repo.path, "2020/01/20200102000000_000.md"].join('/')
    assert FileTest.exist?(filepath)

    content = nil
    File.open(filepath, 'r') { |f|
      content = f.readlines(chomp: true)
    }

    assert_equal text, content
  end

  def test_it_fails_to_create_with_a_existing_timestamp
    repo = Textrepo::FileSystemRepository.new(@config_ro)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = ['overwrite']
    assert_raises(Textrepo::DuplicateTimestampError) {
      repo.create(stamp, text)
    }
  end

  def test_it_fails_to_create_with_empty_text
    repo = Textrepo::FileSystemRepository.new(@config_rw)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 2, 0, 0, 2))
    text = []
    assert_raises(Textrepo::EmptyTextError) {
      repo.create(stamp, text)
    }
  end

  # for `read(timestamp)`
  def test_it_can_read_the_content_of_text_in_the_repository
    repo = Textrepo::FileSystemRepository.new(@config_ro)
    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = repo.read(stamp)
    refute_empty text
  end

  def test_it_fails_to_read_with_a_non_existing_timestamp
    repo = Textrepo::FileSystemRepository.new(@config_ro)
    stamp = Textrepo::Timestamp.new(Time.new(1900, 12, 31, 12, 34, 56))
    assert_raises(Textrepo::MissingTimestampError) {
      repo.read(stamp)
    }
  end

  # for 'update(timestamp, text)'
  def test_it_can_update_the_content_of_text_in_the_repository
    repo_rw = Textrepo::FileSystemRepository.new(@config_rw)

    org_stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = ['content', 'was', 'updated']
    new_stamp = repo_rw.update(org_stamp, text)
    refute_equal org_stamp, new_stamp

    newpath = File.expand_path(new_stamp.to_pathname + '.md', repo_rw.path)
    content = nil
    File.open(newpath, 'r') { |f|
      content = f.readlines(chomp: true)
    }
    assert_equal text, content
  end

  def test_it_fails_to_update_with_a_non_existing_timestamp
    repo_rw = Textrepo::FileSystemRepository.new(@config_rw)

    stamp = Textrepo::Timestamp.new(Time.new(1900, 1, 1, 1, 1, 1))
    text = ['content', 'was', 'updated']
    assert_raises(Textrepo::MissingTimestampError) {
      repo_rw.update(stamp, text)
    }
  end

  def test_it_fails_to_update_with_empty_text
    repo_rw = Textrepo::FileSystemRepository.new(@config_rw)

    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    text = []
    assert_raises(Textrepo::EmptyTextError) {
      repo_rw.update(stamp, text)
    }
  end

  # for `delete(timestamp)`
  def test_it_can_delete_text_in_the_repository
    repo_rw = Textrepo::FileSystemRepository.new(@config_rw)

    stamp = Textrepo::Timestamp.new(Time.new(2020, 1, 1, 1, 0, 0))
    path = File.expand_path(stamp.to_pathname + '.md', repo_rw.path)

    expected = []
    File.open(path, 'r') { |f| expected = f.readlines(chomp: true) }

    content = repo_rw.delete(stamp)
    refute_empty content
    assert_equal expected, content
    refute FileTest.exist?(path)
  end

  def test_it_fails_to_delete_with_a_non_existing_timestamp
    repo_rw = Textrepo::FileSystemRepository.new(@config_rw)

    stamp = Textrepo::Timestamp.new(Time.new(1900, 1, 1, 1, 1, 1))
    assert_raises(Textrepo::MissingTimestampError) {
      repo_rw.delete(stamp)
    }
  end
end
