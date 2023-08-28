# frozen_string_literal: true

# Handles all responsive rendering of station data via Hotwire?Turbo
class StationsController < ApplicationController
  after_action :save_bart_response, if: -> { response.successful? }, only: :show

  def index
    @stations = Station.all
  end

  def show
    @station = Station.find_by_abbr(params[:id])
    render404 and return if bad_station_url

    @station.response = @station.fetch_station_data if @station.stale_response?
    @data = @station.format_station_data
    @time_now = Time.parse(@data['root']['time'][0..-4])
    @time_format = params[:time_format]
    @toggle_format = flip_format(params[:time_format])

    render layout: false
  end

  ### TO DO: ###
  # media queries to change the appearance for different viewport sizes
  # Activate user home station (if set), the same way I open stations (may need new Stimulus home-station-controller)
  # Add user authentication using Devise, then allow setting of home station/convenience links
  # Add closest station finder via google places API
  # add bootstrap Navbar (and footer?), about, contact, favorite stations, ie. (home, work, friend, etc)
  # upsert saved response data to avoid filling up the database?
  # Load saved response data if request to same station is made within 30-60 seconds?
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

  def save_bart_response
    @station.response = @data
    @station.save!
  end

  
end
