# frozen_string_literal: true

# Creates the stations table
class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations do |t|
      t.string :abbr
      t.string :name

      t.timestamps
    end
  end
end
