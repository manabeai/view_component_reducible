# frozen_string_literal: true

RSpec.describe ViewComponentReducible::State::Schema do
  it 'builds defaults for fields' do
    schema = described_class.new
    schema.add_field(:name, default: '')
    schema.add_field(:loading, default: false)

    data = schema.defaults

    expect(data).to eq({ 'name' => '', 'loading' => false })
  end

  it 'supports callable defaults' do
    schema = described_class.new
    schema.add_field(:errors, default: -> { {} })

    data = schema.defaults

    expect(data['errors']).to eq({})
  end

  it 'builds a Data object for reducers' do
    schema = described_class.new
    schema.add_field(:count, default: 0)

    data = schema.build_data({ 'count' => 2 })

    expect(data.count).to eq(2)
    expect(data[:count]).to eq(2)
  end
end
