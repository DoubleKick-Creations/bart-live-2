class StationsController < ApplicationController
  include StationsDataHelper
  
  def index
    @stations = Station.all
  end

  def show
    params[:time_format] == "minutes" || params[:time_format] == "clock" || render_404
    @station = Station.find_by_abbr(params[:id]) || render_404
    @data = get_station_data(@station.abbr)
  
    #empty divs for appending?
    #pass time format as param?
    # lazy loading with spinner?
    # Hash.from_xml?
  end

  def remove
    @station = Station.find_by_abbr(params[:id])
  end
end
