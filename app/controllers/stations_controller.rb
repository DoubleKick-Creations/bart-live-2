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
      #data = mock_data
      station = @data['root']['station']['name']
      super_puts station
      @time_now = Time.parse(@data['root']['time'][0..-4])
      @time_format = params[:time_format]
      @toggle_format = flip_format(params[:time_format])

      render layout: false
    end
    # media queries
    # Stimulus for removing stationTooltips and/or disabling links when one or two are open?
    # Closing tooltips if clicked outside?
    # Use loading: '_top', index turbo frame, and/or class/global variable to prevent more than one station to be open at a time.
    # possibly shoe warning banner when trying to open second frame
    # pure more data in @data hash, ie. @time_now, @time_format, @toggle_format
  end

  def remove
    @station = Station.find_by_abbr(params[:id])
    render layout: false
  end

  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end


end
