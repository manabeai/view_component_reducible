# frozen_string_literal: true

class MyFormComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :count, default: 0
    field :last_updated_at, default: nil
  end

  def reduce(state, msg)
    case msg.type
    when "Increment"
      new_state = state.merge(
        "data" => state["data"].merge(
          "count" => state["data"]["count"] + 1,
          "last_updated_at" => Time.now.utc.iso8601
        )
      )
      [new_state, []]
    when "Decrement"
      next_count = [state["data"]["count"] - 1, 0].max
      new_state = state.merge(
        "data" => state["data"].merge(
          "count" => next_count,
          "last_updated_at" => Time.now.utc.iso8601
        )
      )
      [new_state, []]
    when "Reset"
      new_state = state.merge("data" => state["data"].merge("count" => 0))
      effects = [
        lambda do |controller:, envelope:|
          controller.logger.info("reset count for #{envelope["path"]}")
          ViewComponentReducible::Msg.new(type: "ResetLogged", payload: { "at" => Time.now.utc.iso8601 })
        end
      ]
      [new_state, effects]
    when "ResetLogged"
      new_state = state.merge("data" => state["data"].merge("last_updated_at" => msg.payload["at"]))
      [new_state, []]
    else
      [state, []]
    end
  end
end
