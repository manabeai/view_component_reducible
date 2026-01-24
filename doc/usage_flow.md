# Usage Flow (Web App)

This document describes the minimal end-to-end flow for using ViewComponentReducible in a web app.

## 1. Mount the engine route

Add the engine to your routes.

```ruby
# config/routes.rb
mount ViewComponentReducible::Engine => "/vcr"
```

## 2. Define state in the component

### 2-1. Simple reducer (no effects)

Include the mixin and declare state with the DSL.

```ruby
class MyFormComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :name, default: ""
    field :loading, default: false
  end

  # reduce is equivalent to Elm's update.
  # state is a Data object (use accessors or [])
  def reduce(state, msg)
    case msg
    in { type: :clicked_save }
      case state
      in Data(loading:)
        state.with(loading: true)
      end
    else
      state
    end
  end
end
```

### 2-2. Reducer with effects (emit)

Use effects to emit follow-up messages (often used for data fetching).

```ruby
class MyFormComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :items, default: []
    field :loading, default: false
  end

  def reduce(state, msg)
    case msg
    in { type: :fetch_items }
      effect = build_fetch_effect
      [state.with(loading: true), effect]
    in { type: :items_loaded, payload: payload }
      state.with(items: payload.items || [], loading: false)
    else
      state
    end
  end

  private

  def build_fetch_effect
    emit(:items_loaded, items: fetch_items)
  end

  def fetch_items
    # external call here
    []
  end
end
```

## 3. Render state in the template

Use the values defined in the state DSL. The component output is automatically wrapped
with a `data-vcr-path` boundary based on the envelope path.

```erb
<div>
  <p>Name: <%= vcr_state.name %></p>
  <p>Loading: <%= vcr_state.loading %></p>
</div>
```

## 4. Trigger dispatch to the VCR endpoint

Post a message to `/vcr/dispatch` so it reaches the component reducer.

```erb
<%= vcr_button_to("Save", state: @vcr_state_token, msg_type: :clicked_save) %>
```

## 5. Dispatch flow (summary)

- The request hits `ViewComponentReducible::DispatchController#call`.
- The adapter loads the envelope from `vcr_state`.
- `Msg.from_params` builds the message.
- `Runtime#call` routes to the target component by `vcr_target_path`.
- The component `reduce` runs and updates state.
- Effects can emit follow-up messages via `emit` (returns a `Msg` or callable) and run after state updates.
- The component is re-rendered and the new signed state is injected into the response.
- The injected meta tag + inline script refreshes `input[name="vcr_state"]`.

## 6. Enable partial updates (minimal JS)

Add the dispatcher script in your layout to use the partial update flow.

```erb
<%= vcr_dispatch_script_tag %>
```
