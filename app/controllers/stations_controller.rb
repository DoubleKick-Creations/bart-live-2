class StationsController < ApplicationController
  def index
    @stations = Station.all
  end

  def show
    pp request.params
    @station = Station.find_by_abbr(params[:id])
    #empty divs for appending?
    #pass time format as param?
    # station bubble font
  end
end
