# frozen_string_literal: true

RSpec.describe ViewComponentReducible::State::Schema do
  it 'builds defaults for data and meta fields' do
    schema = described_class.new
    schema.add_field(:name, default: '', kind: :data)
    schema.add_field(:loading, default: false, kind: :meta)

    data, meta = schema.defaults

    expect(data).to eq({ 'name' => '' })
    expect(meta).to eq({ 'loading' => false })
  end

  it 'supports callable defaults' do
    schema = described_class.new
    schema.add_field(:errors, default: -> { {} }, kind: :meta)

    _data, meta = schema.defaults

    expect(meta['errors']).to eq({})
  end
end
