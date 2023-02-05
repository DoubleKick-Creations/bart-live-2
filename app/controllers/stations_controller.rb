class StationsController < ApplicationController
  after_action :save_bart_response, if: -> { response.successful? }, only: :show
  
  def index
    @stations = Station.all
  end

  def show
    @station = Station.find_by_abbr(params[:id])
    render404 and return if bad_station_url
  
    @station.response = @station.fetch_bart_data
    @data = @station.format_station_data
      
    @time_now = Time.parse(@data['root']['time'][0..-4])
    @time_format = params[:time_format]
    @toggle_format = flip_format(params[:time_format])

    render layout: false
  end

  # TO DO:
    # media queries to change the appearance for different viewport sizes
    # Activate user home station (if set), the same way I open stations (may need new Stimulus home-station-controller)
    # Add user authentication using Devise, then allow setting of home station/convenience links
    # add closest station finder via google places API
    # add bootstrap Navbar, about, contact, favorite stations, ie. (home, work, friend, etc)
    
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
