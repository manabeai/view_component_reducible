# State object enhancement (pattern match ready)

Goal:
- Introduce a State object with `deconstruct`/`deconstruct_keys`.
- Enable Ruby pattern matching while keeping current hash-based API usable.

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
  in { "count" => Integer => count }
    # current hash style still works
  end

  case state
  in ViewComponentReducible::State::Object(count:, last_updated_at:)
    # pattern match friendly
  end
end
```

## State object sketch

```ruby
module ViewComponentReducible
  module State
    class Object
      attr_reader :state

      def initialize(state:)
        @state = state
      end

      def deconstruct
        [state]
      end

      def deconstruct_keys(keys)
        keys ? state.slice(*keys) : state
      end

      def to_h
        state
      end
    end
  end
end
```

## Runtime integration
- `Runtime#apply_reducer` builds a `State::Object` instead of a raw hash.
- Reducer returns a flat state hash OR `State::Object`.
- Normalize output before writing to the envelope.

## Compatibility
- Keep `vcr_state` returning a flat hash for templates.
- Provide `vcr_state_object` for advanced usage if needed.

## Incremental steps
1. Introduce `State::Object` and normalization helpers.
2. Allow reducers to return either hash or state object.
3. Add pattern match examples in docs.
