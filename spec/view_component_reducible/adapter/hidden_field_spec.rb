# frozen_string_literal: true

RSpec.describe ViewComponentReducible::Adapter::HiddenField do
  it "round-trips envelope through signed payload" do
    adapter = described_class.new(secret: "secret")
    envelope = { "v" => 1, "data" => { "name" => "A" } }
    request = Struct.new(:params).new({})

    signed = adapter.dump(envelope, request: request)
    request.params["vcr_state"] = signed

    expect(adapter.load(request: request)).to eq(envelope)
  end
end
