# frozen_string_literal: true

RSpec.describe ViewComponentReducible do
  it 'has a version number' do
    expect(ViewComponentReducible::VERSION).not_to be nil
  end

  it 'provides the component mixin' do
    expect(ViewComponentReducible::Component).to be_a(Module)
  end
end
