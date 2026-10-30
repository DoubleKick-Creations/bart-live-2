# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stations', type: :request do
  # Stub the BART API so request specs are fast and never depend on the network.
  let(:api_response) { instance_double(HTTParty::Response, code: 200, parsed_response: payload) }
  let(:api_client) { instance_double(BartAPIClient, call: api_response) }
  let(:payload) { bart_payload }

  before do
    allow(BartAPIClient).to receive(:new).and_return(api_client)
  end

  describe 'GET /' do
    it 'renders the map with the stations in the database' do
      create_station(abbr: '12th', name: '12th St. Oakland City Center')
      create_station(abbr: '16th', name: '16th St. Mission')

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("id='mapContainer'")
      expect(response.body).to include("id='stationsMap'")
      expect(response.body).to include("class='app-header'")
      expect(response.body).to include('12th St. Oakland City Center')
      expect(response.body).to include('16th St. Mission')
    end
  end

  describe 'GET /station/:time_format/:id' do
    it 'renders minutes until the next trains' do
      station = create_station(abbr: '12th', name: '12th St. Oakland City Center')

      get station_path(id: station.abbr, time_format: 'minutes')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('times_frame_12th')
      expect(response.body).to include('Antioch')
      expect(response.body).to include('yellow-line')
      expect(response.body).to include('3,')
      expect(response.body).to include('21 min')
      expect(response.body).to include('Times as of')
      expect(response.body).to include('/station/clock/12th')
    end

    context 'when the station is viewed in clock format' do
      # A fixed response time makes the converted clock times predictable.
      let(:payload) { bart_payload(time: '12:00:00 PM PDT') }

      it 'converts minutes into clock times' do
        station = create_station(abbr: '12th', name: '12th St. Oakland City Center')

        get station_path(id: station.abbr, time_format: 'clock')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('12:03')
        expect(response.body).to include('12:21pm')
        expect(response.body).to include('/station/minutes/12th')
      end
    end
  end

  describe 'caching' do
    it 'stores the fetched BART response on the station' do
      station = create_station(abbr: '12th', name: '12th St. Oakland City Center')

      get station_path(id: station.abbr, time_format: 'minutes')

      expect(response).to have_http_status(:ok)
      expect(station.reload.response.dig('root', 'time')).to eq(payload.dig('root', 'time'))
    end

    it 'keeps serving cached times when the BART API fails' do
      station = create_station(
        abbr: '12th',
        name: '12th St. Oakland City Center',
        response: bart_payload(time: '12:00:00 PM PDT')
      )
      allow(BartAPIClient).to receive(:new).and_return(failing_api_client)

      get station_path(id: station.abbr, time_format: 'minutes')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Antioch')
      expect(response.body).to include('21 min')
      expect(station.reload.response.dig('root', 'time')).to eq('12:00:00 PM PDT')
    end

    it 'shows the unavailable message when there is no cached data and the BART API fails' do
      station = create_station(abbr: '12th', name: '12th St. Oakland City Center')
      allow(BartAPIClient).to receive(:new).and_return(failing_api_client)

      get station_path(id: station.abbr, time_format: 'minutes')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t(:unavailable))
      expect(response.body).not_to include('/station/clock/12th')
    end
  end

  describe 'BART edge cases' do
    context 'when the API returns a single train per line' do
      let(:payload) { bart_payload(trains: :single) }

      it 'wraps it so the view can render it' do
        station = create_station(abbr: '12th', name: '12th St. Oakland City Center')

        get station_path(id: station.abbr, time_format: 'minutes')

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Antioch')
        expect(response.body).to include('3 min')
      end
    end

    it 'shows the after-hours message outside service hours' do
      station = create_station(
        abbr: '12th',
        name: '12th St. Oakland City Center',
        response: bart_payload(message: I18n.t(:after_hours))
      )

      get station_path(id: station.abbr, time_format: 'minutes')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t(:after_hours))
      expect(response.body).not_to include('/station/clock/12th')
    end

    it 'shows the Oakland Airport message instead of train times' do
      station = create_station(
        abbr: 'oakl',
        name: "Oakland Int'l Airport (OAK)",
        response: bart_payload
      )

      get station_path(id: station.abbr, time_format: 'minutes')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t(:oakland_airport))
      expect(response.body).not_to include('/station/clock/oakl')
    end
  end

  describe 'bad requests' do
    it 'returns 404 for an unknown time format' do
      create_station(abbr: '12th', name: '12th St. Oakland City Center')

      get station_path(id: '12th', time_format: 'hours')

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for an unknown station' do
      get station_path(id: 'nope', time_format: 'minutes')

      expect(response).to have_http_status(:not_found)
    end
  end

  def create_station(abbr:, name:, response: {}, latitude: nil, longitude: nil)
    Station.create!(abbr:, name:, response:, latitude:, longitude:)
  end

  describe 'GET /stations/closest_station' do
    before do
      create_station(abbr: 'woak', name: 'West Oakland', latitude: 37.804872, longitude: -122.29514)
      create_station(abbr: 'mlbr', name: 'Millbrae', latitude: 37.600271, longitude: -122.386702)
      create_station(abbr: 'embr', name: 'Embarcadero', latitude: 37.792874, longitude: -122.39702)
    end

    it 'returns West Oakland as the closest station' do
      get closest_station_path, params: { latitude: 37.805, longitude: -122.295 }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('West Oakland')
    end

    it 'returns Millbrae as the closest station' do
      get closest_station_path, params: { latitude: 37.600, longitude: -122.387 }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response.body).to include('Millbrae')
    end

    it 'returns Embarcadero as the closest station' do
      get closest_station_path, params: { latitude: 37.793, longitude: -122.397 }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response.body).to include('Embarcadero')
    end
  end

  def failing_api_client
    instance_double(BartAPIClient).tap do |client|
      allow(client).to receive(:call).and_raise(StandardError, 'BART API is down')
    end
  end

  def bart_payload(time: nil, message: nil, trains: :multiple)
    now = pacific_now
    { 'root' => bart_root(now, time, message, trains) }
  end

  def bart_root(now, time, message, trains)
    {
      'date' => now.strftime('%m/%d/%Y'),
      'time' => time || now.strftime('%I:%M:%S %p %Z'),
      'message' => message,
      'station' => bart_station(trains)
    }
  end

  def bart_station(trains)
    {
      'name' => '12th St. Oakland City Center',
      'abbr' => '12TH',
      'etd' => trains == :single ? single_train : [bart_line]
    }
  end

  def pacific_now
    Time.current.in_time_zone('Pacific Time (US & Canada)')
  end

  def single_train
    line = bart_line
    line.merge('estimate' => line['estimate'].first)
  end

  def bart_line
    {
      'destination' => 'Antioch',
      'abbreviation' => 'ANTC',
      'limited' => '0',
      'estimate' => [bart_estimate('3'), bart_estimate('21')]
    }
  end

  def bart_estimate(minutes)
    {
      'minutes' => minutes,
      'color' => 'YELLOW',
      'hexcolor' => '#ffff33',
      'platform' => '3',
      'direction' => 'North',
      'length' => '9',
      'bikeflag' => '1',
      'delay' => '0'
    }
  end
end
