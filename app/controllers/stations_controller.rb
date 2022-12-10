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
      @time_now = Time.parse(@data['root']['time'][0..-4])
      @time_format = params[:time_format]
      @toggle_format = flip_format(params[:time_format])

      render layout: false
    end
    # media queries
    # Stimulus for removing stationTooltips and/or disabling links when one or two are open?
    # Closing tooltips if clicked outside?
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
