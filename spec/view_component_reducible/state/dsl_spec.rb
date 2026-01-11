# frozen_string_literal: true

RSpec.describe ViewComponentReducible::State::DSL do
  it 'defines vcr_state_schema through state DSL' do
    klass = Class.new do
      include ViewComponentReducible::Component

      state do
        field :name, default: ''
        field :loading, default: false
      end
    end

    schema = klass.vcr_state_schema
    data = schema.defaults

    expect(data).to eq({ 'name' => '', 'loading' => false })
  end
end
