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
    field :errors, default: {}
    field :loading, default: false
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
#      "data" => { "name" => "", "email" => "", "page" => 1, "errors" => {}, "loading" => false },
#      "children" => {}
#    }
```

## Notes

- `field` defines state fields stored under the `data` key in the envelope.
- Defaults can be plain values or callables (e.g., `-> { {} }`).
- Reducers receive a `Data` object with accessor methods for each field.
