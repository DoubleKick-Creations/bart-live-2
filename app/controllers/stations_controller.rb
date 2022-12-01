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
    # eager load spinner, then lazy load stationTooltip turbo grame nested inside spinner turbo_frame_tag id: spinner?
    # reload entire index in turbo frame to remove multip open station tooltips?
    # media queries
    # bootstrap for modals accordians and possibly close buttons
    # 
    # JS for removing stationTooltips:
    # function removeByClass(className) {
    #   document.querySelectorAll(className).forEach(el => { el.remove() });
    # }
    # Conider closing tooltips if clicked outside
  end

  private

  def flip_format(time_format)
    time_format == "minutes" ? "clock" : "minutes"
  end
end
