# frozen_string_literal: true

require 'action_view'
require 'nokogiri'
require 'view_component'

RSpec.describe ViewComponentReducible::Component do
  let(:view_context) { ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil) }

  let(:component_class) do
    Class.new(ViewComponent::Base) do
      include ViewComponentReducible::Component

      state do
        field :count, default: 0
      end

      def call
        content_tag(:div, 'Hello')
      end
    end
  end

  before do
    stub_const('TestComponent', component_class)
  end

  after do
    ViewComponentReducible.registry.clear
  end

  it 'auto registers named components when included' do
    ViewComponentReducible.registry.clear
    stub_const('AutoRegisterComponent', Class.new(ViewComponent::Base))

    AutoRegisterComponent.include(ViewComponentReducible::Component)

    expect(ViewComponentReducible.registry).to include('AutoRegisterComponent' => AutoRegisterComponent)
  end

  it 'wraps rendered output with a VCR boundary when a path is present' do
    component = TestComponent.new(vcr_envelope: { 'path' => 'root/1' })

    html = component.render_in(view_context)

    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    root = fragment.children.find(&:element?)

    expect(root['data-vcr-path']).to eq('root/1')
    expect(root.content).to include('Hello')
  end

  it 'does not wrap output when no envelope is provided' do
    component = TestComponent.new

    html = component.render_in(view_context)

    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    root = fragment.children.find(&:element?)

    expect(root['data-vcr-path']).to be_nil
    expect(root.content).to include('Hello')
  end

  it 'exposes state as an alias for vcr_state' do
    component = TestComponent.new(vcr_envelope: { 'data' => { 'count' => 3 } })

    expect(component.state).to eq(component.vcr_state)
    expect(component.state.count).to eq(3)
  end
end
