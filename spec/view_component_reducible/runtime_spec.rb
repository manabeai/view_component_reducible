# frozen_string_literal: true

require 'action_controller'
require 'action_view'
require 'view_component'

RSpec.describe ViewComponentReducible::Runtime do
  let(:view_context) { ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil) }
  let(:controller) { instance_double(ActionController::Base, view_context:) }

  let(:component_class) do
    Class.new(ViewComponent::Base) do
      include ViewComponentReducible::Component

      state do
        field :count, default: 0
      end

      def call
        content_tag(:div, vcr_state['count'])
      end

      def reduce(state, msg)
        case msg
        in { type: :inc }
          state.with(count: state.count + 1)
        in { type: :inc_array }
          [state.with(count: state.count + 1)]
        in { type: :inc_effect }
          effect = lambda do |**_kwargs|
            ViewComponentReducible::Msg.new(type: 'Inc', payload: { 'source' => 'effect' })
          end
          [state.with(count: state.count + 1), effect]
        else
          state
        end
      end
    end
  end

  let(:envelope) do
    {
      'v' => 1,
      'root' => 'ReducerComponent',
      'path' => 'root/1',
      'data' => { 'count' => 0 },
      'children' => {}
    }
  end

  before do
    stub_const('ReducerComponent', component_class)
    ViewComponentReducible.register(ReducerComponent)
  end

  after do
    ViewComponentReducible.registry.clear
  end

  it 'accepts a reducer that returns only state' do
    msg = ViewComponentReducible::Msg.new(type: 'Inc', payload: {})

    new_env, _html = described_class.new.call(
      envelope:,
      msg:,
      target_path: 'root/1',
      controller:
    )

    expect(new_env['data']['count']).to eq(1)
  end

  it 'accepts a reducer that returns [state]' do
    msg = ViewComponentReducible::Msg.new(type: 'IncArray', payload: {})

    new_env, _html = described_class.new.call(
      envelope:,
      msg:,
      target_path: 'root/1',
      controller:
    )

    expect(new_env['data']['count']).to eq(1)
  end

  it 'accepts a reducer that returns [state, effects...]' do
    msg = ViewComponentReducible::Msg.new(type: 'IncEffect', payload: {})

    new_env, _html = described_class.new.call(
      envelope:,
      msg:,
      target_path: 'root/1',
      controller:
    )

    expect(new_env['data']['count']).to eq(2)
  end
end
