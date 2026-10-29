# frozen_string_literal: true

require 'test_helper'

class StationTest < ActiveSupport::TestCase
  setup do
    @station = stations(:one)
  end

  test 'fetches new data from BartAPIClient when response is 2 minutes old and overwrites existing response' do
    old_time = Time.now.in_time_zone('Pacific Time (US & Canada)') - 200.seconds
    old_response = {
      'root' => {
        'time' => old_time.strftime('%m/%d/%Y %I:%M:%S %p %Z'),
        'station' => {
          'etd' => [{
            'destination' => 'Antioch',
            'abbreviation' => 'ANTC',
            'estimate' => [{ 'minutes' => '5', 'color' => 'YELLOW' }]
          }]
        }
      }
    }
    @station.update_column(:response, old_response)

    new_time = Time.now.in_time_zone('Pacific Time (US & Canada)')
    new_response = {
      'root' => {
        'time' => new_time.strftime('%m/%d/%Y %I:%M:%S %p %Z'),
        'station' => {
          'etd' => [{
            'destination' => 'SFO',
            'abbreviation' => 'SFIA',
            'estimate' => [{ 'minutes' => '3', 'color' => 'RED' }]
          }]
        }
      }
    }

    call_count = 0
    original_new = BartAPIClient.method(:new)
    BartAPIClient.define_singleton_method(:new) do |**_args|
      call_count += 1
      client = Object.new
      client.define_singleton_method(:call) do
        Struct.new(:code, :parsed_response).new(200, new_response)
      end
      client
    end

    begin
      station = Station.find(@station.id)
      station.fetch_station_date
    ensure
      BartAPIClient.define_singleton_method(:new, original_new)
    end

    assert_equal 1, call_count
    station = Station.find(@station.id)
    assert_equal 'SFO', station.response.dig('root', 'station', 'etd', 0, 'destination')
    assert_not_equal old_response['root']['station']['etd'][0]['destination'],
                     station.response.dig('root', 'station', 'etd', 0, 'destination')
    assert_not_equal old_response, station.response
  end

  test 'does not call BartAPIClient when response is 30 seconds old and loads from postgres' do
    recent_time = Time.current.in_time_zone('Pacific Time (US & Canada)') - 30.seconds
    old_response = {
      'root' => {
        'time' => recent_time.strftime('%m/%d/%Y %I:%M:%S %p %Z'),
        'station' => {
          'etd' => [{
            'destination' => 'Antioch',
            'abbreviation' => 'ANTC',
            'estimate' => [{ 'minutes' => '5', 'color' => 'YELLOW' }]
          }]
        }
      }
    }
    @station.update_column(:response, old_response)

    call_count = 0
    original_new = BartAPIClient.method(:new)
    BartAPIClient.define_singleton_method(:new) do |**_args|
      call_count += 1
      raise 'BartAPIClient should not be called'
    end

    begin
      @station.reload.fetch_station_date
    ensure
      BartAPIClient.define_singleton_method(:new, original_new)
    end

    assert_equal 0, call_count
    @station.reload
    assert_equal old_response, @station.response
  end
end
