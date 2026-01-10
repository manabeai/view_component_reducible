# State DSL

This document describes how to use the state DSL.

## Basic usage

Include the component mixin, then define state with `state`.

```ruby
class MyFormComponent
  include ViewComponentReducible::Component

  state do
    field :name, default: ""
    field :email, default: ""
    field :page, default: 1

    meta :errors, default: {}
    meta :loading, default: false
  end
end
```

## Build an initial envelope

```ruby
envelope = ViewComponentReducible::State::Envelope.initial(MyFormComponent)
# => {
#      "v" => 1,
#      "root" => "MyFormComponent",
#      "path" => "root",
#      "data" => { "name" => "", "email" => "", "page" => 1 },
#      "children" => {},
#      "meta" => { "errors" => {}, "loading" => false }
#    }
```

## Notes

- `field` defines data fields stored under the `data` key.
- `meta` defines metadata fields stored under the `meta` key.
- Defaults can be plain values or callables (e.g., `-> { {} }`).
