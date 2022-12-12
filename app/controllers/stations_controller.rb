class StationsController < ApplicationController
  include StationsDataHelper
  
  def index
    @stations = Station.all
  end

  def show
    @station = Station.find_by_abbr(params[:id])
    
    unless @station
      render404  
    else
      @data = get_station_data(@station.abbr)
      station_name = @data['root']['station']['name']
      super_puts station_name
      @time_now = Time.parse(@data['root']['time'][0..-4])
      @time_format = params[:time_format]
      @toggle_format = flip_format(params[:time_format])
      

      render layout: false
    end
  end
  # media queries
  # Stimulus for removing stationTooltips and/or disabling links when one or two are open?
  # Closing tooltips if clicked outside?
  # Use loading: '_top', index turbo frame, and/or class/global variable to prevent more than one station open at a time.
  # possibly show warning banner when trying to open second frame
  # put more data in @data object, ie. @time_now, @time_format, @toggle_format
  # call remove on any open frames, when new one is clicked, or remove/close all when any new frame is clicked/opened
  # store number of open stations, or store the abbr for open station in class variable, local store, or cookies?
  # enhance 'reveal' stimulus controller to handle closing any open stations prior to opening new station

  def remove
    @station = Station.find_by_abbr(params[:id])
    render layout: false
  end

  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end


end
