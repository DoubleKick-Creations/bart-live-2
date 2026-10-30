# frozen_string_literal: true

# Handles all responsive rendering of station data via Hotwire?Turbo
class StationsController < ApplicationController
  before_action :set_station, only: :show
  # after_action :update_response, only: :show

  def index
    @stations = Station.all
  end

  def closest_station
    lat = params[:latitude]
    lng = params[:longitude]
    @station = FindClosestStation.new(latitude: lat, longitude: lng).call
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  def show
    render404 and return if bad_station_url

    @data = @station.fetch_station_date
    @time_now = @station.response_time
    @time_format = params[:time_format]
    @toggle_format = flip_format(params[:time_format])

    render layout: false
  end

  ### TO DO: ###
  # Activate user home station (if set), the same way I open stations (may need new Stimulus home-station-controller)
  # Add user authentication using Devise, then allow setting of home station/convenience links
  # Add closest station finder via google places API
  # add bootstrap Navbar (and footer?), about, contact, favorite stations, ie. (home, work, friend, etc)
  # Use Redis to cache responses instead of postgres?
  # Use Turbo Streams to create Reminder notifications for trains at a set time
  # Add reminder model, controller, and modal view for creating reminders

  private

  def bad_station_url
    @station.blank? || params[:time_format] != 'minutes' && params[:time_format] != 'clock'
  end

  def flip_format(time_format)
    time_format == 'minutes' ? 'clock' : 'minutes'
  end

  def set_station
    @station = Station.find_by_abbr(params[:id])
  end
end
