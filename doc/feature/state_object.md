# State object enhancement (pattern match ready)

Goal:
- Use Ruby's `Data` for state with `deconstruct`/`deconstruct_keys`.
- Enable Ruby pattern matching while keeping hash-based view access.

## Motivation
- Improve readability in reducers using `case ... in` patterns.
- Provide a stable place for invariants and helpers.
- Keep minimal runtime overhead for v0.1 users.

## Proposed API

```ruby
state do
  field :count, default: 0
  field :last_updated_at, default: nil
end

def reduce(state, msg)
  case state
  in Data(count:, last_updated_at:)
    # pattern match friendly
  end
end
```

## State object sketch

```ruby
## Runtime integration
- `Runtime#apply_reducer` builds a `Data` object instead of a raw hash.
- Reducer returns a flat state hash OR `Data`.
- Normalize output before writing to the envelope.

## Compatibility
- Keep `vcr_state` returning a flat hash for templates.
- Data accessors are available in reducers.

## Incremental steps
1. Introduce `State::Object` and normalization helpers.
2. Allow reducers to return either hash or state object.
3. Add pattern match examples in docs.
