# frozen_string_literal: true

require 'cgi'
require 'nokogiri'
require 'rails_helper'

RSpec.describe 'VCR dispatch', type: :request do
  it 'updates state via dispatch' do
    vcr_dispatch(type: :increment, component: CounterComponent)

    expect(response).to have_http_status(:ok)
    html = CGI.unescapeHTML(response.body)
    doc = Nokogiri::HTML.fragment(html)

    expect(doc.at_css('[data-testid="count"]').text).to eq('1')
  end
end
