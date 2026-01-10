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
      html.include?("</head>") ? html.sub("</head>", "#{meta}</head>") : (meta + html)
    end
  end
end
