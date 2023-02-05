class AddResponseToStations < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :response, :jsonb, default: {}
  end
end
