# frozen_string_literal: true

# Class handles the data fetching and a number of edge cases created by the BART API
class Station < ApplicationRecord
  validates :abbr, presence: true
  validates :name, presence: true

  def fetch_station_data
    http_response = BartAPIClient.new(abbr:).call
    raise StandardError('Bart API request failure') if http_response.code.to_i != 200

    http_response.parsed_response
  end

  def format_station_data # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    update_response if stale_response?

    return { 'root' => { 'message' => I18n.t(:unavailable) } } if response.blank?

    return response_with_message(I18n.t(:oakland_airport)) if oakl_airport?
    return response_with_message(I18n.t(:after_hours)) if after_hours?
    return response_with_message(I18n.t(:unavailable)) if api_down?

    response['root']['station']['etd'] = [response['root']['station']['etd']] if one_train?

    all_train_times.each do |line|
      line['estimate'] = [line['estimate']] unless line['estimate'].is_a?(Array)
    end
    response
  end

  def oakl_airport?
    abbr == 'oakl'
  end

  def after_hours?
    response.dig('root', 'message').present?
  end

  def api_down?
    response.dig('root', 'station', 'message', 'error') == I18n.t(:api_down)
  end

  def times_unavailable?
    response.blank? || oakl_airport? || after_hours? || api_down?
  end

  def response_time
    Time.zone = 'Pacific Time (US & Canada)'
    time = response.dig('root', 'time')
    time.present? ? Time.parse(time).to_datetime : Time.current.to_datetime
  end

  # Method for poor man's caching in Postgres to avoid hitting the BART API too often
  def stale_response?(delay = 1.minute)
    return true if response.blank? || response.dig('root', 'time').blank?

    Time.zone = 'Pacific Time (US & Canada)'
    Time.now.to_datetime > response_time + delay # Need times to match types for comparison
  end

  def update_response
    update(response: fetch_station_data)
  rescue StandardError => e
    # Keep serving the last saved response when the BART API is unavailable
    Rails.logger.error("BART API response error for #{abbr}: #{e.message}")
  end

  private

  def response_with_message(message)
    response['root'] ||= {}
    response['root']['message'] = message
    response
  end

  def two_or_more_trains?
    response['root']['station']['etd'].is_a?(Array)
  end

  # BART API sends multiple trains per line in an array, but does no array is sent for a single train
  # As a result, single trains must be wrapped in arrays to prevent view parsing from breakin
  def one_train?
    !two_or_more_trains?
  end

  def all_train_times
    response['root']['station']['etd']
  end
end
