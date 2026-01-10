# Partial updates (boundary + JS)

Goal:
- Identify component boundaries in HTML.
- Dispatch to the target component by path.
- Replace only the target DOM with minimal JS.

## Boundary markup
Each component should render a wrapper with a path marker:

```erb
<%= helpers.vcr_boundary(path: vcr_envelope["path"]) do %>
  ...
<% end %>
```

This produces:

```html
<div data-vcr-path="root/0"> ... </div>
```

## Partial response flow
- Client sends `vcr_partial=1` along with the message.
- Server dispatches the message, then renders the target component only.
- Server returns:
  - response body: target component HTML
  - response header: `X-VCR-State` (new signed token)

## Minimal client script
Use the helper to inject the JS dispatcher:

```erb
<%= vcr_dispatch_script_tag %>
```

Behavior:
- Intercepts `<form data-vcr-form>` submissions.
- Sends `fetch` to the VCR endpoint.
- Parses returned HTML and replaces the element matching `data-vcr-path`.
- Updates all `input[name="vcr_state"]` with `X-VCR-State`.

## API surface
- `ViewComponentReducible::Helpers#vcr_boundary`
- `ViewComponentReducible::Helpers#vcr_dispatch_form`
- `ViewComponentReducible::Helpers#vcr_dispatch_script_tag`
- `ViewComponentReducible::Runtime#render_target`
- `ViewComponentReducible::DispatchController#call` (supports `vcr_partial`)
