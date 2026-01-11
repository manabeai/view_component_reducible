# frozen_string_literal: true

require 'json'

module ViewComponentReducible
  # Message payload sent from the client.
  Msg = Struct.new(:type, :payload, keyword_init: true) do
    # Enable pattern matching with normalized symbol types.
    # @param keys [Array<Symbol>, nil]
    # @return [Hash{Symbol=>Object}]
    def deconstruct_keys(keys)
      payload_hash = { type: normalized_type, payload: payload }
      keys ? payload_hash.slice(*keys) : payload_hash
    end

    # Build a Msg from request params.
    # @param params [Hash]
    # @return [ViewComponentReducible::Msg]
    def self.from_params(params)
      type = params.fetch('vcr_msg_type')
      payload_json = params['vcr_msg_payload']
      payload = payload_json && payload_json != '' ? JSON.parse(payload_json) : {}
      new(type:, payload:)
    end

    private

    def normalized_type
      type.to_s
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
          .to_sym
    end
  end
end
