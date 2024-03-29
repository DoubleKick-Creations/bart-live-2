# frozen_string_literal: true

# Class handles the data fetching and a number of edge cases created by the BART API
class Station < ApplicationRecord
  validates :abbr, presence: true
  validates :name, presence: true

  BART_API_KEY = Rails.application.credentials.bart_api_key

  def fetch_station_data
    bart_query_uri = Addressable::URI.new(
      scheme: 'http',
      host: 'api.bart.gov',
      path: 'api/etd.aspx',
      query_values: { cmd: 'etd', orig: abbr, key: BART_API_KEY }
    )
    HTTParty.get(bart_query_uri)
  end

  def format_station_data # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    update_response # if stale_response?

    if oakl_airport?
      response['root']['message'] = I18n.t(:oakland_airport)
      return response
    end

    if after_hours?
      response['root']['message'] = I18n.t(:after_hours)
      return response
    end

    if api_down?
      response['root']['message'] = I18n.t(:unavailable)
      return response
    end

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
    response['root']['message'].present?
  end

  def api_down?
    response['root']['station']['message'] &&
      response['root']['station']['message']['error'] == I18n.t(:api_down)
  end

  def times_unavailable?
    oakl_airport? || after_hours? || api_down?
  end

  def response_time
    Time.zone = 'Pacific Time (US & Canada)'
    Time.parse(response['root']['time']).to_datetime # Need times to match types for comparison
  end

  # Method for poor man's caching in Postgres to avoid hitting the BART API too often
  def stale_response?(delay = 1.minute)
    return true if response.blank?

    Time.zone = 'Pacific Time (US & Canada)'
    time_now = Time.now.to_datetime
    ## DEBUGGING ##
    puts "time now: #{time_now}"
    puts "response time: #{response_time + delay}"
    puts "time now > response time + delay: #{time_now > response_time + delay}"

    time_now > response_time + delay # Need times to match types for comparison
  end

  def update_response
    update(response: fetch_station_data)
  end

  private

  def two_or_more_trains?
    response['root']['station']['etd'].is_a?(Array)
  end

  # BART API sends multiple trains per line in an array, but does not for a single train
  # single trains need to be wrapped in arrays to prevent view parsing from breakin
  def one_train?
    !two_or_more_trains?
  end

  def all_train_times
    response['root']['station']['etd']
  end
end
