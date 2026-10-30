# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindClosestStation do
  before do
    Station.create!(abbr: 'woak', name: 'West Oakland', latitude: 37.804872, longitude: -122.29514)
    Station.create!(abbr: 'mlbr', name: 'Millbrae', latitude: 37.600271, longitude: -122.386702)
    Station.create!(abbr: 'embr', name: 'Embarcadero', latitude: 37.792874, longitude: -122.39702)
  end

  it 'returns West Oakland for a point near West Oakland' do
    result = described_class.new(latitude: 37.805, longitude: -122.295).call
    expect(result.abbr).to eq('woak')
  end

  it 'returns Millbrae for a point near Millbrae' do
    result = described_class.new(latitude: 37.600, longitude: -122.387).call
    expect(result.abbr).to eq('mlbr')
  end

  it 'returns Embarcadero for a point near Embarcadero' do
    result = described_class.new(latitude: 37.793, longitude: -122.397).call
    expect(result.abbr).to eq('embr')
  end
end