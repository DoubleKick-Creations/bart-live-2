class StationsController < ApplicationController
  include StationsDataHelper
  
  def index
    @stations = Station.all
  end

  def show
    @station = Station.find_by_abbr(params[:id])
    
    if @station.blank?
      render404  
    else
      @data = get_station_data(@station.abbr) 
      @time_now = Time.parse(@data['root']['time'][0..-4])
      @time_format = params[:time_format]
      @toggle_format = flip_format(params[:time_format]) 
      super_puts @data['root']['station']['name'] # Debugging output to know which station is being rendered
      render layout: false
    end
  end
  # put id="station" or other unique identifier on the open station, look for it in controller, if exists, prevent new station from opening, show warning, etc.
  # media queries for different viewport sizes and orientations
  # Stimulus for opening stationTooltips and/or disabling links when trying to open more than one ?
  # Closing tooltips if clicked outside?
  # Using @@class variables to prevent more than one station open at a time may be a dead end.
  # Possibly create and show warning banner when trying to open second station?
  # Posssibly call removeon more than one open ubject, when new one is clicked, or remove/close all when any new frame is clicked/opened
  # Store number of open stations, or store the abbr for open station in class variable, local store, or cookies?
  # enhance 'reveal' stimulus controller to handle closing any open stations prior to opening new station!

  def remove
    @station = Station.find_by_abbr(params[:id])
    render layout: false
  end

  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end

end
