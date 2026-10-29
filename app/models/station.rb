# frozen_string_literal: true

POSTGRESQL_CACHING_DELAY = 1.minutes # Serve saved JSONB response for this many minutes before hitting the BART API again

# Class handles the data fetching and a number of edge cases created by the BART API
class Station < ApplicationRecord
  validates :abbr, presence: true
  validates :name, presence: true

  def fetch_station_data
    http_response = BartAPIClient.new(abbr:).call
    raise StandardError('Bart API request failure') if http_response.code.to_i != 200

    http_response.parsed_response
  end

  def fetch_station_date # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if stale_response? || response.blank?
      update_response
      reload
    end

    return { 'root' => { 'message' => I18n.t(:unavailable) } } if response.blank?

    return response_with_message(I18n.t(:oakland_airport)) if oakl_airport?
    return response_with_message(I18n.t(:after_hours)) if after_hours?
    return response_with_message(I18n.t(:unavailable)) if api_down?

    response['root']['station']['etd'] = [response.dig('root', 'station', 'etd')] if one_train?

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
    root = response&.dig('root') || {}
    time = root['time']
    date = root['date']
    string_to_parse = [date, time].compact_blank.join(' ')

    return current_pacific_time if string_to_parse.blank?

    [
      -> { Time.strptime(string_to_parse, '%m/%d/%Y %I:%M:%S %p %Z') },
      -> { Time.zone.parse(string_to_parse) },
      -> { Time.parse(string_to_parse) }
    ].each do |parser|
      parsed = parser.call
      return parsed.in_time_zone('Pacific Time (US & Canada)').to_datetime
    rescue ArgumentError
      next
    end

    current_pacific_time
  end

  def current_pacific_time
    Time.current.in_time_zone('Pacific Time (US & Canada)').to_datetime
  end

  # Method for poor man's caching in Postgres to avoid hitting the BART API too often
  def stale_response?(delay = POSTGRESQL_CACHING_DELAY)
    return true if response.blank? || response.dig('root', 'time').blank?

    Time.zone = 'Pacific Time (US & Canada)'
    now = Time.current.in_time_zone('Pacific Time (US & Canada)').to_datetime
    now > response_time + delay
  end

  def update_response
    new_data = fetch_station_data
    update_columns(response: new_data, updated_at: Time.current)
    self.response = new_data
    self.updated_at = Time.current
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
