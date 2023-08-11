# frozen_string_literal: true

# Base application controller with 404 rendering that all other controllers inherit from
class ApplicationController < ActionController::Base
  def render404
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
