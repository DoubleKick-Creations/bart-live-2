# frozen_string_literal: true

# Service object that, given a latitude/longitude, finds the closest Station.
class FindClosestStation
  attr_reader :latitude, :longitude

  def initialize(latitude:, longitude:)
    @latitude = latitude.to_f
    @longitude = longitude.to_f
  end

  def call
    Station.where.not(latitude: nil, longitude: nil).min_by do |station|
      haversine_distance(station.latitude, station.longitude)
    end
  end

  private

  # Great-circle distance in kilometers (units don't matter for comparison).
  def haversine_distance(lat2, lon2)
    rad = Math::PI / 180
    dlat = (lat2 - latitude) * rad
    dlon = (lon2 - longitude) * rad
    a = Math.sin(dlat / 2)**2 +
        Math.cos(latitude * rad) * Math.cos(lat2 * rad) * Math.sin(dlon / 2)**2
    2 * 6371 * Math.asin(Math.sqrt(a))
  end
end