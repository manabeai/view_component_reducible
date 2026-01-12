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
      build(type:, payload:)
    end

    # Build a Msg with a normalized payload object.
    # @param type [String, Symbol]
    # @param payload [Object, nil]
    # @return [ViewComponentReducible::Msg]
    def self.build(type:, payload: nil)
      return new(type:, payload:) if payload.is_a?(Data)

      normalized = normalize_type(type)
      new(type:, payload: self::Payload.from_hash(normalized, payload))
    end

    # @param type [String, Symbol]
    # @return [Symbol]
    def self.normalize_type(type)
      type.to_s
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
          .to_sym
    end

    private

    def normalized_type
      self.class.normalize_type(type)
    end
  end

  class Msg
    module Payload
      Empty = Data.define
      Value = Data.define(:value)

      def self.from_hash(_type, payload)
        payload_hash = payload.is_a?(Hash) ? payload.transform_keys(&:to_s) : nil

        return Empty.new if payload.nil? || (payload.respond_to?(:empty?) && payload.empty?)
        return Value.new(value: payload) unless payload_hash

        build_generic(payload_hash)
      end

      def self.build_generic(payload_hash)
        return Empty.new if payload_hash.empty?

        keys = payload_hash.keys.map(&:to_sym)
        klass = Data.define(*keys)
        values = keys.to_h { |key| [key, payload_hash[key.to_s]] }
        klass.new(**values)
      end
    end
  end
end
