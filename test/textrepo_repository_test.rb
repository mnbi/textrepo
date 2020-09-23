require "test_helper"

class TextrepoRepositoryTest < Minitest::Test
  def setup
    @config = {
      :repository_type => :file_system,
      :repository_name => "test_repo",
      :repository_base => File.expand_path("fixtures", __dir__)
    }
  end

  def test_it_has_init_method_to_get_concrete_repository_instance
    repo = Textrepo.init(@config)
    assert repo
  end

  def test_it_fails_when_unknown_type_was_specified_as_repository_type
    config = @config.clone
    config[:repository_type] = :foo_bar
    assert_raises(Textrepo::UnknownRepoTypeError) {
      Textrepo.init(config)
    }
  end
end
