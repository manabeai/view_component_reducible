# frozen_string_literal: true

class FakeRedis
  def initialize
    @store = {}
  end

  def setex(key, _ttl, value)
    @store[key] = value
  end

  def set(key, value)
    @store[key] = value
  end

  def get(key)
    @store[key]
  end
end

RSpec.describe ViewComponentReducible::Adapter::Redis do
  it 'stores envelope in redis and loads it by signed key' do
    adapter = described_class.new(secret: 'secret', redis: FakeRedis.new)
    envelope = { 'v' => 1, 'data' => { 'name' => 'A' } }
    request = Struct.new(:params).new({})

    signed = adapter.dump(envelope, request: request)
    request.params['vcr_state_key'] = signed

    expect(adapter.load(request: request)).to eq(envelope)
  end
end
