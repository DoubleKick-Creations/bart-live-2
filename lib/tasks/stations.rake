# frozen_string_literal: true

namespace :stations do
  desc 'Populate latitude and longitude for all stations from the BART stns API'
  task populate_locations: :environment do
    response = BartAPIClient.all_stations
    raise "BART API request failure: #{response.code}" unless response.code.to_i == 200

    stations_data = response.parsed_response.dig('root', 'stations', 'station')
    stations_data = [stations_data] unless stations_data.is_a?(Array)

    stations_data.each do |data|
      station = Station.where('LOWER(abbr) = ?', data['abbr'].downcase).first
      station ||= Station.new(abbr: data['abbr'].downcase)
      station.name = data['name'] if station.name.blank?
      station.latitude = data['gtfs_latitude'].to_f
      station.longitude = data['gtfs_longitude'].to_f
      station.save!
      puts "Updated #{station.abbr}: #{station.latitude}, #{station.longitude}"
    end

    puts "Done. #{stations_data.size} stations processed."
  end
end