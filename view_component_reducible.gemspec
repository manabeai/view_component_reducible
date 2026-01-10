# frozen_string_literal: true

require_relative "lib/view_component_reducible/version"

Gem::Specification.new do |spec|
  spec.name = "view_component_reducible"
  spec.version = ViewComponentReducible::VERSION
  spec.authors = ["manabeai"]
  spec.email = ["matsu.devtool@gmail.com"]

  spec.summary       = "Reducer-based state transitions for Rails ViewComponent"
  spec.description   = <<~DESC
    view_component_reducible brings reducer-style (TEA-inspired) state transitions
    to Rails ViewComponent. Server-driven, HTTP-based, no WebSocket required.
  DESC
  spec.homepage      = "https://github.com/manabeai/view_component_reducible"

  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = Dir.glob("lib/**/*") + %w[README.md LICENSE]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
