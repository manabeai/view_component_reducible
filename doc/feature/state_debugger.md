# State debugger (timeline)

Goal:
- Provide a timeline UI that shows dispatched messages and state snapshots.
- Enable a debug mode to inspect server-driven updates without external tools.

## Scope (v0)
- Toggle debug mode via configuration.
- Capture:
  - request timestamp
  - msg type + payload
  - target path
  - before/after state
- Render a simple timeline in HTML, appended to the response.

## Proposed API

```ruby
ViewComponentReducible.configure do |config|
  config.debug = true
end
```

## Data model

```ruby
DebugEntry = Struct.new(
  :at,
  :msg_type,
  :payload,
  :target_path,
  :before,
  :after,
  keyword_init: true
)
```

## Runtime hooks (idea)
- When dispatch starts:
  - capture `before` state for the target path
- After reducer/effects:
  - capture `after` state
  - append entry to a debug timeline store

Storage options:
- Session (simple, per-user)
- Request-local (only for the current response)
- In-memory (dev only)

## Rendering
- Append a small panel to HTML when `debug` is on:
  - `Dispatch.inject_state` can also inject `DebugPanel.render(entries)`
- Panel layout:
  - fixed bottom-right
  - list of entries with time, msg, target_path
  - expand to show before/after diff

## Security
- Debug mode must be off by default.
- Only enabled in development or with explicit flag.
- Do not serialize sensitive data in production.

## Minimal UI sketch

```erb
<aside class="vcr-debugger">
  <h3>VCR Timeline</h3>
  <ol>
    <li>
      <strong>12:00:01</strong> Increment @ root
      <details>
        <summary>state</summary>
        <pre>before: {...}</pre>
        <pre>after: {...}</pre>
      </details>
    </li>
  </ol>
</aside>
```
