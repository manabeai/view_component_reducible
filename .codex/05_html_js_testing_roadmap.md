# HTML contract, JS, testing, roadmap

## Required hidden fields (for dispatch POST)
`vcr_dispatch_form` が生成する hidden fields:
- `vcr_state` (signed)
- `vcr_msg_type`
- `vcr_msg_payload`
- `vcr_target_path`

## DOM targeting (for AJAX replace)
Each component root should have:
- `data-vcr-path="root/uuid"`

## Minimal JS for AJAX (progressive enhancement)
Goal:
- Without JS: normal POST works, full page HTML returned
- With JS: intercept forms marked `data-vcr-form` and replace `data-vcr-path` subtree only

Protocol:
- Client sends `X-Requested-With: XMLHttpRequest`
- Server returns partial HTML and `X-VCR-State` header
- JS updates only the boundary's `input[name="vcr_state"]`

```js
// lib/view_component_reducible/helpers.rb (vcr_dispatch_script_tag)
(function () {
  document.addEventListener("submit", function (event) {
    var form = event.target;
    if (!(form instanceof HTMLFormElement)) return;
    if (!form.matches("[data-vcr-form]")) return;

    event.preventDefault();
    var formData = new FormData(form);
    formData.append("vcr_partial", "1");

    fetch(form.action, {
      method: (form.method || "POST").toUpperCase(),
      body: formData,
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
      .then(function (response) {
        var state = response.headers.get("X-VCR-State");
        return response.text().then(function (html) {
          return { html: html, state: state };
        });
      })
      .then(function (payload) {
        var targetPath = formData.get("vcr_target_path");
        var parser = new DOMParser();
        var doc = parser.parseFromString(payload.html, "text/html");
        var newNode = doc.querySelector('[data-vcr-path="' + targetPath + '"]') || doc.body.firstElementChild;
        var current = document.querySelector('[data-vcr-path="' + targetPath + '"]');
        if (newNode && current) {
          current.replaceWith(newNode);
        }
        if (payload.state) {
          var boundary = document.querySelector('[data-vcr-path="' + targetPath + '"]');
          if (boundary) {
            boundary.querySelectorAll('input[name="vcr_state"]').forEach(function (input) {
              input.value = payload.state;
            });
          }
        }
      });
  });
})();
```

## Dispatch endpoint shape (server)
Client form target:
- action: `/vcr/dispatch`
- method: POST

Params:
- `vcr_state` (signed)
- `vcr_msg_type`
- `vcr_msg_payload` (JSON string)
- `vcr_target_path`

Optional (future):
- `vcr_render = full|partial`
- `vcr_format = html|turbo_stream`

## Example component implementation
```rb
class CounterComponent < ViewComponentReducible::Component
  state do
    field :count, default: 0
    meta :errors, default: {}
  end

  def reduce(state, msg)
    data = state["data"]
    case msg.type
    when "Inc"
      data["count"] += 1
      [state, []]
    when "Dec"
      data["count"] -= 1
      [state, []]
    else
      [state, []]
    end
  end

  def initialize(vcr_envelope:)
    @vcr_envelope = vcr_envelope
  end

  def call
    count = @vcr_envelope["data"]["count"]
    # render buttons as forms posting to /vcr/dispatch
    # (helper usage omitted)
    <<~HTML.html_safe
      <div data-vcr-path="#{@vcr_envelope["path"]}">
        <p>#{count}</p>
        <form action="/vcr/dispatch" method="post" data-vcr-form="true">
          <input type="hidden" name="vcr_state" value="">
          <input type="hidden" name="vcr_msg_type" value="Inc">
          <input type="hidden" name="vcr_msg_payload" value="{}">
          <input type="hidden" name="vcr_target_path" value="#{@vcr_envelope["path"]}">
          <button type="submit">+</button>
        </form>
      </div>
    HTML
  end
end
```

## Testing (RequestSpec-first)
RequestSpec pattern:
```rb
get "/demo"
doc = Nokogiri::HTML(response.body)
state = doc.at_css("input[name=vcr_state]")["value"]

post "/vcr/dispatch", params: {
  vcr_state: state,
  vcr_msg_type: "Inc",
  vcr_msg_payload: "{}",
  vcr_target_path: "root"
}

expect(response).to have_http_status(:ok)
expect(response.body).to include(">1<")
```

## Testing (E2E with Playwright)
- Dummy app lives in `spec/dummy/`.
- Playwright tests live in `spec/e2e/`.
- Run: `npm install` then `npx playwright install` and `npm run test:e2e`.

## Implementation milestones
v0.1 (this spec):
- HiddenField adapter signing
- Dispatch controller
- Runtime: reduce + effects loop
- Full root re-render
- Minimal JS replace (optional)

v0.2:
- Partial render (target subtree)
- Turbo Frame/Stream integration
- Child component tree routing helpers

v0.3:
- Better schema typing/coercion
- Stable child identity + keyed collections
- Effect helpers (db fetch, validation, navigation)
