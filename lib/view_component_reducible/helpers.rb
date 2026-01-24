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

    # Build a dispatch button form with hidden fields for the VCR endpoint.
    # @param state [String, nil] signed state token (defaults to current component token)
    # @param msg_type [String]
    # @param msg_payload [Hash, String]
    # @param target_path [String, nil]
    # @param url [String]
    # @param button_attrs [Hash]
    # @yield block for the form body (e.g., submit button)
    # @return [String]
    def vcr_button_to(label = nil, msg_type:, **options, &block)
      msg_payload = options.fetch(:msg_payload, {})
      payload = msg_payload.is_a?(String) ? msg_payload : JSON.generate(msg_payload)
      resolved_state = options.fetch(:state, nil) || instance_variable_get(:@vcr_state_token)
      target_path = options.fetch(:target_path, nil)
      resolved_target = target_path || vcr_envelope_path || instance_variable_get(:@vcr_current_path) || 'root'
      component_context = instance_variable_defined?(:@vcr_current_path) || !vcr_envelope_path.nil?
      if resolved_state.nil? && !component_context
        raise ArgumentError, 'vcr_state is missing. Pass state: or render inside a component.'
      end

      resolved_state = '' if resolved_state.nil?
      state_param = ViewComponentReducible.config.adapter.state_param_name
      button_body = block_given? ? capture(&block) : label
      raise ArgumentError, 'vcr_button_to requires a label or block.' if button_body.nil?

      button_attrs = options.fetch(:button_attrs, {})
      url = options.fetch(:url, '/vcr/dispatch')

      form_tag(url, method: :post, data: { vcr_form: true, vcr_state_param: state_param }) do
        body = [
          hidden_field_tag(state_param, resolved_state),
          hidden_field_tag('vcr_msg_type', msg_type),
          hidden_field_tag('vcr_msg_payload', payload),
          hidden_field_tag('vcr_target_path', resolved_target),
          content_tag(:button, button_body, { type: 'submit' }.merge(button_attrs))
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
                    var stateParam = form.dataset.vcrStateParam || "vcr_state";
                    boundary.querySelectorAll('input[name="' + stateParam + '"]').forEach(function(input) {
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

    # Backward compatibility alias.
    # @deprecated Use vcr_button_to instead.
    def vcr_dispatch_form(...)
      vcr_button_to(...)
    end

    def vcr_envelope_path
      return unless respond_to?(:vcr_envelope) && vcr_envelope

      vcr_envelope['path']
    end
  end
end
