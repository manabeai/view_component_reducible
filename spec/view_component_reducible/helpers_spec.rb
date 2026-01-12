# frozen_string_literal: true

require 'action_view'

RSpec.describe ViewComponentReducible::Helpers do
  it 'builds a dispatch form with hidden fields' do
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    view.extend(described_class)

    html = view.vcr_dispatch_form(
      state: 'token',
      msg_type: 'Ping',
      msg_payload: { 'id' => 1 },
      target_path: 'root/1'
    ) { 'Go' }

    expect(html).to include('name="vcr_state"')
    expect(html).to include('value="token"')
    expect(html).to include('name="vcr_msg_type"')
    expect(html).to include('value="Ping"')
    expect(html).to include('name="vcr_msg_payload"')
    expect(html).to include('id')
    expect(html).to include('name="vcr_target_path"')
    expect(html).to include('value="root/1"')
    expect(html).to include('data-vcr-form="true"')
    expect(html).to include('>Go<')
  end

  it 'wraps content with a boundary' do
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    view.extend(described_class)

    html = view.vcr_boundary(path: 'root/1') { 'Inside' }

    expect(html).to include('data-vcr-path="root/1"')
    expect(html).to include('Inside')
  end

  it 'defaults target_path to the current component path' do
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    view.extend(described_class)
    view.instance_variable_set(:@vcr_current_path, 'root/2')

    html = view.vcr_dispatch_form(state: 'token', msg_type: 'Ping') { 'Go' }

    expect(html).to include('name="vcr_target_path"')
    expect(html).to include('value="root/2"')
  end
end
