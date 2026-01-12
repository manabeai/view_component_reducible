# frozen_string_literal: true

RSpec.describe ViewComponentReducible::Msg do
  it 'parses type and payload from params' do
    params = {
      'vcr_msg_type' => 'ClickedSave',
      'vcr_msg_payload' => '{"id":123}'
    }

    msg = described_class.from_params(params)

    expect(msg.type).to eq('ClickedSave')
    expect(msg.payload.id).to eq(123)
  end

  it 'defaults payload to an empty payload object' do
    params = { 'vcr_msg_type' => 'Ping', 'vcr_msg_payload' => '' }

    msg = described_class.from_params(params)

    expect(msg.payload.to_h).to eq({})
  end

  it 'supports pattern matching with symbol types' do
    msg = described_class.build(type: 'SelectDay', payload: { day: 2 })

    matched = case msg
              in { type: :select_day, payload: { day: 2 } }
                true
              else
                false
              end

    expect(matched).to eq(true)
  end
end
