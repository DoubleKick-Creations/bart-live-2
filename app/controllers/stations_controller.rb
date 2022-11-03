class StationsController < ApplicationController
  include StationsDataHelper
  
  def index
    @stations = Station.all
  end

  def show
    @station = Station.find_by_abbr(params[:id])
    
    if @station.nil? || params[:time_format] != "minutes" && params[:time_format] != "clock" 
      render404
    else
      @data = get_station_data(@station.abbr)
      @time_format = params[:time_format]
      @toggle_format = params[:time_format] == "minutes" ? "clock" : "minutes"
      render layout: false
    end
    #empty divs for appending?
    #pass time format as param?
    # lazy loading with spinner?
    # Hash.from_xml?
  end

  def remove
    @station = Station.find_by_abbr(params[:id])
  end
end
