# frozen_string_literal: true

class IncrementalSearchComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  ITEMS = [
    "Adapter",
    "Component",
    "Counter",
    "Dispatch",
    "Envelope",
    "Helpers",
    "Message",
    "Reducer",
    "Registry",
    "Runtime",
    "State",
    "ViewComponent"
  ].freeze

  state do
    field :query, default: ""
    field :results, default: -> { ITEMS }
  end

  def reduce(state, msg)
    case msg
    in { type: :set_query, payload: payload }
      query = payload.query.to_s
      state.with(query: query, results: filter_items(query))
    in { type: :reset }
      state.with(query: "", results: ITEMS)
    end
  end

  private

  def filter_items(query)
    return ITEMS if query.empty?

    needle = query.downcase
    ITEMS.select { |item| item.downcase.include?(needle) }
  end
end
