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

      render layout: false
    end
  end
  # media queries to change the appearance for different viewport sizes
  # keeping 'remove' route for now, but may switch close_links to '#' later if doing so doesn't shift the app around too much.


  def remove
    @station = Station.find_by_abbr(params[:id])
    render layout: false
  end

  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end

end
