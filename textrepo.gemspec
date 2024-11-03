require_relative 'lib/textrepo/version'

Gem::Specification.new do |spec|
  spec.name          = "textrepo"
  spec.version       = Textrepo::VERSION
  spec.authors       = ["mnbi"]
  spec.email         = ["mnbi@users.noreply.github.com"]

  spec.summary       = %q{A repository to store text with timestamp.}
  spec.description   = %q{Textrepo is a repository to store text with timestamp.  It can manage text with the attached timestamp (create/read/update/delete).}
  spec.homepage      = "https://github.com/mnbi/textrepo"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mnbi/textrepo"
  spec.metadata["changelog_uri"] = "https://github.com/mnbi/textrepo/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.5"
end
