class AddResponseToStations < ActiveRecord::Migration[7.0]
  def change
    add_column :stations, :response, :jsonb, null: false, default: {}
  end
end
