class StationsController < ApplicationController
  include StationsDataHelper
  
  def index
    @stations = Station.all
  end

  def show
    #pp request.params
    @station = Station.find_by_abbr(params[:id])
    #@data = get_station_data(@station.abbr)
    @data = mock_data
    #empty divs for appending?
    #pass time format as param?
    # lazy loading with spinner?
    # Hash.from_xml?
  end

  def remove
    @station = Station.find_by_abbr(params[:id])
  end
end
