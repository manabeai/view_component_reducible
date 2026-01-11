# frozen_string_literal: true

require "action_view"
require "view_component"

RSpec.describe ViewComponentReducible::Component do
  let(:view_context) { ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil) }

  let(:component_class) do
    Class.new(ViewComponent::Base) do
      include ViewComponentReducible::Component

      def call
        "Hello"
      end
    end
  end

  it "wraps rendered output with a VCR boundary when a path is present" do
    component = component_class.new(vcr_envelope: { "path" => "root/1" })

    html = component.render_in(view_context)

    expect(html).to include('data-vcr-path="root/1"')
    expect(html).to include("Hello")
  end

  it "does not wrap output when no envelope is provided" do
    component = component_class.new

    html = component.render_in(view_context)

    expect(html).not_to include("data-vcr-path")
    expect(html).to include("Hello")
  end
end
