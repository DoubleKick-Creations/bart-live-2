class StationsController < ApplicationController
  def index
    @stations = Station.all
  end

  def show
  end
end
