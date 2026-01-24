# frozen_string_literal: true

module ViewComponentReducible
  # rubocop:disable Metrics/ModuleLength
  # Dispatch helpers for partial updates.
  module DispatchHelpers
    # Insert the minimal JS dispatcher for partial updates.
    # @return [String]
    def vcr_dispatch_script_tag
      js = <<~JS
        (function() {
          if (window.__vcrDispatchInstalled) return;
          window.__vcrDispatchInstalled = true;
          if (!document.getElementById("vcr-update-style")) {
            var style = document.createElement("style");
            style.id = "vcr-update-style";
            style.textContent = '::view-transition-old(root), ::view-transition-new(root) { animation: none; } #vcr-debug-bar { view-transition-name: vcr-debug-bar; } ::view-transition-old(vcr-debug-bar), ::view-transition-new(vcr-debug-bar) { animation: none; }';
            document.head.appendChild(style);
          }
          document.addEventListener("submit", function(event) {
            var form = event.target;
            if (!(form instanceof HTMLFormElement)) return;
            if (!form.matches("[data-vcr-form]")) return;
            event.preventDefault();
            var submitter = event.submitter || document.activeElement;
            var source = null;
            var sourceId = null;
            var transitionEnabled = true;
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
                  if (payload.state) {
                    var stateParam = form.dataset.vcrStateParam || "vcr_state";
                    newNode.querySelectorAll('input[name="' + stateParam + '"]').forEach(function(input) {
                      input.value = payload.state;
                    });
                  }
                  if (document.startViewTransition && transitionEnabled) {
                    var transitionName = "vcr-boundary-" + String(targetPath || "root").replace(/[^a-zA-Z0-9_-]/g, "_");
                    current.style.viewTransitionName = transitionName;
                    newNode.style.viewTransitionName = transitionName;
                    var transition = document.startViewTransition(function() {
                      current.replaceWith(newNode);
                    });
                    var clearTransition = function() {
                      current.style.viewTransitionName = "";
                      newNode.style.viewTransitionName = "";
                    };
                    if (transition && transition.finished) {
                      transition.finished
                        .then(function() {
                          clearTransition();
                        })
                        .catch(function() {
                          clearTransition();
                        });
                    } else {
                      clearTransition();
                    }
                  } else {
                    current.replaceWith(newNode);
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
  # rubocop:enable Metrics/ModuleLength
end
