# frozen_string_literal: true

BART_API_KEY = Rails.application.credentials.bart_api_key

class BartAPIClient
  attr_reader :station_abbr

  def initialize(abbr:)
    @station_abbr = abbr
  end

  def call
    bart_query_uri = Addressable::URI.new(
      scheme: 'http',
      host: 'api.bart.gov',
      path: 'api/etd.aspx',
      query_values: { cmd: 'etd', orig: station_abbr, key: BART_API_KEY }
    )
    HTTParty.get(bart_query_uri)
  end
end
