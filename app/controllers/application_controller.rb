class ApplicationController < ActionController::Base
  
  def render404
    raise ActionController::RoutingError.new('Not Found')
  end
end
