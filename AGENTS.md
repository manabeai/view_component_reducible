# Repository Guidelines

## Project Structure & Module Organization
- Core library code lives in `lib/`, with the gem entrypoint in `lib/view_component_reducible.rb` and version pinning in `lib/view_component_reducible/version.rb`.
- Tests are in `spec/`, using RSpec; add new specs alongside the feature under test and suffix files with `_spec.rb`.
- Executables and setup scripts are in `bin/` (`bin/setup` for dependencies, `bin/console` for an interactive sandbox).
- Type signatures sit in `sig/` as `.rbs` files; keep these updated when public APIs change.
- Gem metadata and packaging rules are in `view_component_reducible.gemspec`; update it when adding files or changing dependencies.

## Build, Test, and Development Commands
- `bin/setup` — install dependencies via Bundler; run this first.
- `bundle exec rspec` or `bundle exec rake spec` — execute the full RSpec suite; the default Rake task also runs specs.
- `bundle exec rake build` — build the gem package; use before release artifacts.
- `bin/console` — open an IRB session with the gem loaded for quick experiments.

## Coding Style & Naming Conventions
- Target Ruby `>= 3.1`; keep `# frozen_string_literal: true` at the top of Ruby files.
- Use two-space indentation, snake_case for methods/variables, and CamelCase for classes/modules under the `ViewComponentReducible` namespace.
- Prefer double quotes for strings unless interpolation is unnecessary and consistency suggests otherwise.
- No linter is configured; follow idiomatic Ruby and keep methods small and focused. Update `sig/` types when changing public interfaces.
- Add YARD docstrings for public APIs.

## Testing Guidelines
- Write specs with clear `describe`/`context` blocks and expectation messages; keep unit tests fast.
- Name files `*_spec.rb` and mirror the path of the code under test (e.g., `lib/view_component_reducible/foo.rb` → `spec/view_component_reducible/foo_spec.rb`).
- Ensure new behavior is covered; avoid leaving placeholder failing specs in the suite.
- ensure run test by file changed

## Commit & Pull Request Guidelines
- Use short, imperative commit messages (e.g., `Update gemspec to include LICENSE.txt in gem files`); group related changes per commit when possible.
- Pull requests should include: a summary of the change, rationale/motivation, testing notes (`bundle exec rspec` output), and linked issues when applicable.
- Request reviews early for interface changes that affect `sig/` files or gem packaging. Add screenshots or examples if the change impacts developer ergonomics or documentation.
