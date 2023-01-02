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
  # getting rid of remove route by sending 'X' close links to root_url, check 'limit-open-station' branch if reversion is necessary
  # activate user home station (if set), the same way I open stations (may need new Stimulus home-station-controller)
  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end

end
