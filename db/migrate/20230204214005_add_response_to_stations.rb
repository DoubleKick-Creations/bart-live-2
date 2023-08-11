# frozen_string_literal: true

# Adds a JSONB column to store responses for potential loading times from the DB instead of the API
# Only useable if is fairly recent, ie. within 30-60 seconds of last request to station
class AddResponseToStations < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :response, :jsonb, default: {}
  end
end
