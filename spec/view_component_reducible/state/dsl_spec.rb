# frozen_string_literal: true

RSpec.describe ViewComponentReducible::State::DSL do
  it 'defines vcr_state_schema through state DSL' do
    klass = Class.new do
      include ViewComponentReducible::Component

      state do
        field :name, default: ''
        meta :loading, default: false
      end
    end

    schema = klass.vcr_state_schema
    data, meta = schema.defaults

    expect(data).to eq({ 'name' => '' })
    expect(meta).to eq({ 'loading' => false })
  end
end
