# frozen_string_literal: true

require 'json'

module ViewComponentReducible
  # Message payload sent from the client.
  Msg = Struct.new(:type, :payload, keyword_init: true) do
    # Build a Msg from request params.
    # @param params [Hash]
    # @return [ViewComponentReducible::Msg]
    def self.from_params(params)
      type = params.fetch('vcr_msg_type')
      payload_json = params['vcr_msg_payload']
      payload = payload_json && payload_json != '' ? JSON.parse(payload_json) : {}
      new(type:, payload:)
    end
  end
end
