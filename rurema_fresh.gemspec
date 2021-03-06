# frozen_string_literal: true

require_relative "lib/rurema_fresh/version"

Gem::Specification.new do |spec|
  spec.name          = "rurema_fresh"
  spec.version       = RuremaFresh::VERSION
  spec.authors       = ["universato"]
  spec.email         = ["universato@gmail.com"]

  spec.summary       = "るりまの古い分岐を削除し綺麗にします。"
  spec.description   = "簡単に、るりまの古い分岐を削除できます。since, until, if の古い分岐を削除し、可能であれば if を since や until に置き換えます。"
  spec.homepage      = "https://github.com/universato/rurema_fresh"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/universato/rurema_fresh"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
