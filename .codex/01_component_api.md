# Component base class (public API)

```rb
# lib/view_component_reducible/component.rb
module ViewComponentReducible
  class Component < ViewComponent::Base
    # required: unique component id for dispatching
    def self.vcr_id = name

    # state schema DSL
    def self.state(&block) = ViewComponentReducible::State::DSL.define(self, &block)

    # required: reducer
    # @return [Array(new_state, effects)]
    def reduce(state, msg)
      raise NotImplementedError
    end

    # required: render entry
    # render should read values from state only
    def call
      raise NotImplementedError
    end

    # optional: choose which DOM node is the replace target
    def vcr_dom_id(path:) = "vcr:#{self.class.vcr_id}:#{path}"
  end
end
```

Notes:
- Reducer must not directly perform IO. Use effects.
- `call` uses `@state` (set by runtime) and renders HTML.

