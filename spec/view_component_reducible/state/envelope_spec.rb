# frozen_string_literal: true

RSpec.describe ViewComponentReducible::State::Envelope do
  it 'builds the initial envelope from schema defaults' do
    klass = Class.new do
      include ViewComponentReducible::Component

      def self.name = 'MyFormComponent'

      state do
        field :name, default: ''
        field :loading, default: false
      end
    end

    envelope = described_class.initial(klass)

    expect(envelope).to eq(
      {
        'v' => 1,
        'root' => 'MyFormComponent',
        'path' => 'root',
        'data' => { 'name' => '', 'loading' => false },
        'children' => {}
      }
    )
  end
end
