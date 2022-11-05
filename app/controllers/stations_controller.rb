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
      @time_format = params[:time_format]
      @toggle_format = flip_format(params[:time_format])
      render layout: false
    end
    # lazy loading with spinner?
  end

  def remove
    @station = Station.find_by_abbr(params[:id])
  end

  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end
end
