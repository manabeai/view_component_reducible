# HTML contract, JS, testing, roadmap

## Required hidden fields (for dispatch POST)
Inside the component root (or form):
- `vcr_state` (signed)
- `vcr_msg_type`
- `vcr_msg_payload`
- `vcr_target_path`

Suggested helper:
```rb
# lib/view_component_reducible/helpers.rb
def vcr_hidden_fields(signed_state:, msg_type:, msg_payload:, target_path:)
  safe_join([
    hidden_field_tag("vcr_state", signed_state),
    hidden_field_tag("vcr_msg_type", msg_type),
    hidden_field_tag("vcr_msg_payload", msg_payload.to_json),
    hidden_field_tag("vcr_target_path", target_path),
  ])
end
```

## DOM targeting (for AJAX replace)
Each component root should have:
- `data-vcr-path="root/0/2"`
- `id="vcr:ComponentId:root/0/2"` (or equivalent)
- `data-vcr-root="true"` on root

## Minimal JS for AJAX (progressive enhancement)
Goal:
- Without JS: normal POST works, full page HTML returned
- With JS: intercept forms marked `data-vcr-remote="true"` and replace a target DOM node with server HTML

Protocol:
- Client sends `Accept: text/html`
- Server returns HTML containing `<meta name="vcr-state" content="...">`
- JS reads meta and updates all `input[name=vcr_state]` within replaced subtree

```js
// app/assets/javascripts/view_component_reducible.js
(function () {
  function getMetaState(doc) {
    var meta = doc.querySelector('meta[name="vcr-state"]');
    return meta ? meta.getAttribute("content") : null;
  }

  function updateStateInputs(rootEl, signedState) {
    if (!signedState) return;
    rootEl.querySelectorAll('input[name="vcr_state"]').forEach(function (inp) {
      inp.value = signedState;
    });
  }

  document.addEventListener("submit", function (e) {
    var form = e.target;
    if (!(form instanceof HTMLFormElement)) return;
    if (form.dataset.vcrRemote !== "true") return;

    e.preventDefault();

    var targetSelector = form.dataset.vcrTarget; // e.g. "#vcr\\:MyRoot\\:root"
    var targetEl = targetSelector ? document.querySelector(targetSelector) : form.closest("[data-vcr-root='true']");
    if (!targetEl) targetEl = document.body;

    fetch(form.action, {
      method: form.method.toUpperCase(),
      body: new FormData(form),
      headers: { "Accept": "text/html" },
      credentials: "same-origin"
    })
      .then(function (res) { return res.text(); })
      .then(function (html) {
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, "text/html");
        var signedState = getMetaState(doc);

        // Replace strategy:
        // - if server renders full page, try to pick matching target by id
        // - else fallback to body
        var incoming = null;
        if (targetEl.id) incoming = doc.getElementById(targetEl.id);
        if (!incoming) incoming = doc.body;

        targetEl.outerHTML = incoming.outerHTML;

        // after replacement: update state inputs in the new subtree
        var newTarget = document.getElementById(incoming.id) || document.querySelector("[data-vcr-root='true']") || document.body;
        updateStateInputs(newTarget, signedState);
      })
      .catch(function (err) {
        console.error("[vcr] remote submit failed", err);
        form.submit(); // graceful fallback
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
      <div data-vcr-root="true" data-vcr-path="#{@vcr_envelope["path"]}" id="#{vcr_dom_id(path: @vcr_envelope["path"])}">
        <p>#{count}</p>

        <form action="/vcr/dispatch" method="post" data-vcr-remote="true" data-vcr-target="##{css_escape(vcr_dom_id(path: @vcr_envelope["path"]))}">
          <input type="hidden" name="vcr_state" value="">
          <input type="hidden" name="vcr_msg_type" value="Inc">
          <input type="hidden" name="vcr_msg_payload" value="{}">
          <input type="hidden" name="vcr_target_path" value="#{@vcr_envelope["path"]}">
          <button type="submit">+</button>
        </form>
      </div>
    HTML
  end

  private

  def css_escape(id) = id.gsub(":", "\\:")
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

