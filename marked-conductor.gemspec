# frozen_string_literal: true

require_relative "lib/conductor/version"

Gem::Specification.new do |spec|
  spec.name = "marked-conductor"
  spec.version = Conductor::VERSION
  spec.authors = ["Brett Terpstra"]
  spec.email = ["me@brettterpstra.com"]

  spec.summary = "A custom processor manager for Marked 2 (Mac)"
  spec.description = "Conductor allows easy configuration of multiple scripts" \
                     "which are run as custom pre/processors for Marked based on conditional statements."
  spec.homepage = "https://github.com/ttscoff/marked-conductor"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ttscoff/marked-conductor"
  spec.metadata["changelog_uri"] = "https://github.com/ttscoff/marked-conductor/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "awesome_print", "~> 1.9.2"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "gem-release", "~> 2.2"
  spec.add_development_dependency "parse_gemspec-cli", "~> 1.0"
  spec.add_development_dependency "pry", "~> 0.14.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "simplecov-console", "~> 0.9"
  spec.add_development_dependency "yard", "~> 0.9", ">= 0.9.26"

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "chronic", "~> 0.10.2"
  spec.add_dependency "tty-which", "~> 0.5.0"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
