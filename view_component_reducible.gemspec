# frozen_string_literal: true

require_relative 'lib/view_component_reducible/version'

Gem::Specification.new do |spec|
  spec.name = 'view_component_reducible'
  spec.version = ViewComponentReducible::VERSION
  spec.authors = ['manabeai']
  spec.email = ['matsu.devtool@gmail.com']

  spec.summary       = 'Reducer-based state transitions for Rails ViewComponent'
  spec.description   = <<~DESC
    This gem is intentionally published early. The API is unstable, but the idea is stable.
    view_component_reducible brings reducer-style (TEA-inspired) state transitions
    to Rails ViewComponent. Server-driven, HTTP-based, no WebSocket required.
  DESC
  spec.homepage = 'https://github.com/manabeai/view_component_reducible'

  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  # point source and changelog to the repository
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  File.basename(__FILE__)
  spec.files = Dir.glob('lib/**/*') + %w[README.md LICENSE.txt]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 6.1'
  spec.add_dependency 'activesupport', '>= 6.1'
  spec.add_dependency 'nokogiri', '>= 1.14'
  spec.add_dependency 'railties', '>= 6.1'
  spec.add_dependency 'redis', '>= 4.0'
  spec.add_dependency 'view_component', '>= 2.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
