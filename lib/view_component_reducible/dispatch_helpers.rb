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
          function vcrEscapeSelector(value) {
            if (window.CSS && CSS.escape) return CSS.escape(value);
            return String(value).replace(/["\\]/g, '\\$&');
          }
          document.addEventListener("input", function(event) {
            var input = event.target;
            if (!(input instanceof HTMLInputElement)) return;
            if (!input.matches("[data-vcr-live-input]")) return;
            var form = input.closest("form[data-vcr-form][data-vcr-live]");
            if (!form) return;
            var payloadField = form.querySelector('input[name="vcr_msg_payload"]');
            if (payloadField) {
              var payloadKey = payloadField.dataset.vcrPayloadKey || input.name;
              var payloadValue = input.value || "";
              payloadField.value = JSON.stringify({ [payloadKey]: payloadValue });
            }
            var submitter = form.querySelector("[data-vcr-live-submit]");
            if (submitter) {
              submitter.click();
            } else if (form.requestSubmit) {
              form.requestSubmit();
            } else {
              var fallback = document.createElement("button");
              fallback.type = "submit";
              fallback.style.display = "none";
              form.appendChild(fallback);
              fallback.click();
              fallback.remove();
            }
          });
          document.addEventListener("submit", function(event) {
            var form = event.target;
            if (!(form instanceof HTMLFormElement)) return;
            if (!form.matches("[data-vcr-form]")) return;
            event.preventDefault();
            var submitter = event.submitter || document.activeElement;
            var source = null;
            var sourceId = null;
            if (submitter && submitter instanceof HTMLElement) {
              source = submitter.getAttribute("data-vcr-source") ||
                submitter.getAttribute("aria-label") ||
                (submitter.textContent || "").trim() ||
                submitter.tagName.toLowerCase();
              sourceId = submitter.getAttribute("data-vcr-source-id");
            }
            var formData = new FormData(form);
            formData.append("vcr_partial", "1");
            var eventType = formData.get("vcr_msg_type");
            var activeElement = document.activeElement;
            var focusInfo = null;
            if (activeElement && activeElement.matches && activeElement.matches("[data-vcr-live-input]")) {
              focusInfo = {
                name: activeElement.name,
                selectionStart: activeElement.selectionStart,
                selectionEnd: activeElement.selectionEnd
              };
            }
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
                if (focusInfo && focusInfo.name) {
                  var boundary = document.querySelector('[data-vcr-path="' + targetPath + '"]') || document;
                  var selector = '[data-vcr-live-input][name="' + vcrEscapeSelector(focusInfo.name) + '"]';
                  var nextInput = boundary.querySelector(selector);
                  if (nextInput) {
                    nextInput.focus();
                    if (typeof nextInput.setSelectionRange === "function") {
                      var start = focusInfo.selectionStart || 0;
                      var end = focusInfo.selectionEnd || start;
                      nextInput.setSelectionRange(start, end);
                    }
                  }
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
                  detail.source_id = sourceId || detail.source_id;
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
