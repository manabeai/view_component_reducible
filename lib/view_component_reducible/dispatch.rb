# frozen_string_literal: true

require "erb"

module ViewComponentReducible
  # Helpers for dispatch responses.
  module Dispatch
    # Inject a signed state token into HTML.
    # @param html [String]
    # @param signed_state [String]
    # @return [String]
    def self.inject_state(html, signed_state)
      meta = %(<meta name="vcr-state" content="#{ERB::Util.html_escape(signed_state)}">)
      script = <<~SCRIPT.chomp
        <script>
        (function() {
          var meta = document.querySelector('meta[name="vcr-state"]');
          if (!meta) return;
          var state = meta.getAttribute('content');
          var inputs = document.querySelectorAll('input[name="vcr_state"]');
          inputs.forEach(function(input) { input.value = state; });
        })();
        </script>
      SCRIPT

      injection = meta + script
      html.include?("</head>") ? html.sub("</head>", "#{injection}</head>") : (injection + html)
    end
  end
end
