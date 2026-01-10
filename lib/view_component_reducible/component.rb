# frozen_string_literal: true

module ViewComponentReducible
  # Include to enable the component state DSL and helpers.
  module Component
    # Hook to include DSL and class methods.
    # @param base [Class]
    # @return [void]
    def self.included(base)
      base.include(State::DSL)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Stable component identifier for envelopes.
      # @return [String]
      def vcr_id
        name.to_s
      end
    end
  end
end
