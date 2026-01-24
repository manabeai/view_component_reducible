# frozen_string_literal: true

module ViewComponentReducible
  # Dispatch helpers for partial updates.
  module DispatchHelpers
    # Insert the minimal JS dispatcher for partial updates.
    # @return [String]
    def vcr_dispatch_script_tag
      js = <<~JS
        (function() {
          if (window.__vcrDispatchInstalled) return;
          window.__vcrDispatchInstalled = true;
          document.addEventListener("submit", function(event) {
            var form = event.target;
            if (!(form instanceof HTMLFormElement)) return;
            if (!form.matches("[data-vcr-form]")) return;
            event.preventDefault();
            var submitter = event.submitter || document.activeElement;
            var source = null;
            if (submitter && submitter instanceof HTMLElement) {
              source = submitter.getAttribute("data-vcr-source") ||
                submitter.getAttribute("aria-label") ||
                (submitter.textContent || "").trim() ||
                submitter.tagName.toLowerCase();
            }
            var formData = new FormData(form);
            formData.append("vcr_partial", "1");
            var eventType = formData.get("vcr_msg_type");
            var headers = { "X-Requested-With": "XMLHttpRequest" };
            if (window.__vcrDebugEnabled) headers["X-VCR-Debug"] = "1";
            fetch(form.action, {
              method: (form.method || "POST").toUpperCase(),
              body: formData,
              headers: headers
            })
              .then(function(response) {
                var state = response.headers.get("X-VCR-State");
                var debug = response.headers.get("X-VCR-Debug");
                return response.text().then(function(html) {
                  return { html: html, state: state, debug: debug };
                });
              })
              .then(function(payload) {
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
                    var stateParam = form.dataset.vcrStateParam || "vcr_state";
                    boundary.querySelectorAll('input[name="' + stateParam + '"]').forEach(function(input) {
                      input.value = payload.state;
                    });
                  }
                }
                if (payload.debug) {
                  var detail = {};
                  try {
                    detail = JSON.parse(payload.debug);
                  } catch (e) {
                    detail = {};
                  }
                  detail.event_type = detail.msg_type || eventType;
                  detail.source = source || detail.source;
                  detail.path = detail.path || targetPath;
                  window.dispatchEvent(new CustomEvent("vcr:debug", { detail: detail }));
                }
              });
          });
        })();
      JS
      content_tag(:script, js.html_safe)
    end
  end
end
