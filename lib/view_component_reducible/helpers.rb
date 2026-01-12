# frozen_string_literal: true

require 'json'

module ViewComponentReducible
  # View helpers for dispatching messages to the VCR endpoint.
  module Helpers
    # Wrap component markup with a boundary for partial updates.
    # @param path [String]
    # @yield block for component content
    # @return [String]
    def vcr_boundary(path:, &block)
      content_tag(:div, capture(&block), data: { vcr_path: path })
    end

    # Build a dispatch form with hidden fields for the VCR endpoint.
    # @param state [String] signed state token
    # @param msg_type [String]
    # @param msg_payload [Hash, String]
    # @param target_path [String, nil]
    # @param url [String]
    # @yield block for the form body (e.g., submit button)
    # @return [String]
    def vcr_dispatch_form(state:, msg_type:, msg_payload: {}, target_path: nil, url: '/vcr/dispatch', &block)
      payload = msg_payload.is_a?(String) ? msg_payload : JSON.generate(msg_payload)
      resolved_target = target_path || vcr_envelope_path || instance_variable_get(:@vcr_current_path) || 'root'

      form_tag(url, method: :post, data: { vcr_form: true }) do
        body = [
          hidden_field_tag('vcr_state', state),
          hidden_field_tag('vcr_msg_type', msg_type),
          hidden_field_tag('vcr_msg_payload', payload),
          hidden_field_tag('vcr_target_path', resolved_target),
          (block_given? ? capture(&block) : '')
        ]
        safe_join(body)
      end
    end

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
            var formData = new FormData(form);
            formData.append("vcr_partial", "1");
            fetch(form.action, {
              method: (form.method || "POST").toUpperCase(),
              body: formData,
              headers: { "X-Requested-With": "XMLHttpRequest" }
            })
              .then(function(response) {
                var state = response.headers.get("X-VCR-State");
                return response.text().then(function(html) {
                  return { html: html, state: state };
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
                    boundary.querySelectorAll('input[name="vcr_state"]').forEach(function(input) {
                      input.value = payload.state;
                    });
                  }
                }
              });
          });
        })();
      JS
      content_tag(:script, js.html_safe)
    end

    def vcr_envelope_path
      return unless respond_to?(:vcr_envelope) && vcr_envelope

      vcr_envelope['path']
    end
  end
end
