# Component base class (public API)

```rb
# lib/view_component_reducible/component.rb
module ViewComponentReducible
  module Component
    def self.included(base)
      base.include(State::DSL)
      base.extend(ClassMethods)
    end

    attr_reader :vcr_envelope

    def initialize(vcr_envelope: nil, **kwargs)
      @vcr_envelope = vcr_envelope
      return unless defined?(super)
      kwargs.empty? ? super() : super(**kwargs)
    end

    def vcr_state
      return { "data" => {}, "meta" => {} } if vcr_envelope.nil?
      schema = self.class.vcr_state_schema
      data, meta = schema.build(vcr_envelope["data"], vcr_envelope["meta"])
      { "data" => data, "meta" => meta }
    end

    def vcr_dom_id(path:) = "vcr:#{self.class.vcr_id}:#{path}"

    module ClassMethods
      def vcr_id = name.to_s
    end
  end
end
```

Notes:
- Reducer must not directly perform IO. Use effects.
- `reduce` is equivalent to Elm's `update` (state + msg -> new_state + effects).
- `call` reads from `vcr_state` or `vcr_envelope` and renders HTML.
- Components include the mixin: `include ViewComponentReducible::Component`.
