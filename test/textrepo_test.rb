require "test_helper"

class TextrepoTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Textrepo::VERSION
  end
end
