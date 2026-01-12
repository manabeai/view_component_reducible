# view_component_reducible — Overview

## What
`view_component_reducible` is a server-driven, HTTP-based TEA/reducer-style architecture for Rails ViewComponent.

- UI is a pure-ish projection of state: `view(state) -> HTML`
- User actions are Msg: `{ type, payload }`
- State transition is reducer: `reduce(state, msg) -> state | [state] | [state, effects...]`
- Effects are explicit and executed on the server, optionally producing follow-up Msg
- No WebSocket required
- Minimal JS only for optional partial updates (AJAX); without JS it still works (progressive enhancement)

## Why
- Make UI behavior explainable by state transitions
- Make complex UI testable via RequestSpec (click/submit -> request -> response)
- Keep JS as wiring, not logic
- Preserve Rails operational ergonomics (SSR, caching, security model)

## Core Concepts

### State
Serializable, signed envelope that can round-trip between client and server (hidden field) or be stored on server (session adapter).

### Msg
Represents an intention/event. Examples:
- `TypedName`, `ClickedSave`, `LoadNextPage`
- Effects return messages like `SavedOk`, `ValidatedError`

### Reducer (Update)
Pure-ish function: given current state and message, returns the next state and optional effects.

### Effect
Explicit side effect; executed by server runtime. Should be deterministic at boundaries and return a Msg (or nil).

### Component Tree (path routing)
Nested components form a tree. Each node has a `path` (e.g. `root/0/2`) to route messages precisely.

## Architecture (request flow)
1. Render initial page (SSR)
2. User action submits `signed_state + msg`
3. Dispatch controller verifies & decodes state, routes msg to target component/path
4. Reducer runs, effects run, final state produced
5. Re-render either:
   - full page HTML, or
   - partial HTML (only target/root component), or
   - Turbo Stream (optional)
6. Response includes updated `signed_state`

## Integration Surface
- `ViewComponentReducible::Component` base class (or mixin)
- `state DSL` to define state schema defaults
- `adapter` to store state (hidden field / session)
- `dispatch route` and controller
- minimal JS (optional) to replace HTML of a target DOM node

## Non-goals (v0)
- Real-time sync, WS
- Client-side state reconciliation
- Full virtual DOM diff
- Background jobs orchestration (effects are synchronous in v0)

## Repository layout (recommended)
```
lib/
  view_component_reducible.rb
  view_component_reducible/
    version.rb
    component.rb
    state/
      dsl.rb
      schema.rb
      envelope.rb
    msg.rb
    effect.rb
    runtime.rb
    adapter/
      base.rb
      hidden_field.rb
      session.rb
    dispatch/
      controller.rb
      router.rb
    railtie.rb
```
